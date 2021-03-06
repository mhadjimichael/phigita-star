//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Winnow.cpp                                    =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//===========================================================

#include "Winnow.h"
#include "Target.h"
#include "GlobalParams.h"
#include <math.h>
#include <iomanip>
#include <map>


void Winnow::UpdateCounts( Target& tar, Example& ex )
{
  int i;
  Target::FeatureMap::iterator f;

  for (i = 0; i < ex.features.Size(); ++i)
  {
    if (tar.FeatureIsLinkable(ex.features[i].id))
    {
      // Does the feature already exist?
      if ((f = tar.features.find(ex.features[i].id)) != tar.features.end()
          && f->second.eligibility != pending)
        ++(f->second.activeCount);
      else
      {
        // either feature doesn't exist or is pending
        int actualCount;

        if (f != tar.features.end())
        {
          ++(f->second.activeCount);
          actualCount = f->second.activeCount;
        }
        // else add the feature
        else
        {
          tar.features.insert(make_pair(ex.features[i].id,
                                        MinimalFeature(0, 1, pending)));
          actualCount = 1;
        }

        // Check the eligibility of the feature
        if (actualCount >= globalParams.eligibilityThreshold)
        {
          if (globalParams.verbosity >= VERBOSE_MAX)
            *globalParams.pResultsOutput << "Winnow adding feature ("
                                         << ex.features[i].id
                                         << ") to target (" << tar.targetID
                                         << ")\n";

          // If it is eligible, set its weight
          tar.features[ex.features[i].id].eligibility = eligible;
          tar.features[ex.features[i].id].weight = defaultWeight;
        }
      }
    } 
  }
}


// Presents an example to the Target's classifier.  The return value indicates
// whether the Target's classifier made a mistake on this example (and had its
// weight vector updated).  Return of true indicates a mistake and update,
// otherwise false.

bool Winnow::PresentExample( Target& tar, Example& ex )
{
  // Reset activation flags
  int target_index = ex.features.find_target(tar.targetID);
  if ((tar.externalActivation = target_index != -1))
    tar.strength = ex.features[target_index].strength;

  // Update the active / non-active counters
  if (globalParams.currentCycle <= 1)
  {
    if (tar.externalActivation || !globalParams.sparseNetwork)
      UpdateCounts(tar, ex);
    if (tar.externalActivation) ++tar.activeCount; 
    else ++tar.nonActiveCount;
  }

  if (!((globalParams.currentCycle > 1 || !globalParams.noFirstCycleUpdate
          || globalParams.currentCycle == 0)
        && (!globalParams.gradientDescent || tar.externalActivation)))
    return false;

  Target::FeatureMap::iterator f;

  tar.internalActivation = 0.0;
  for (int i = 0; i < ex.features.Size(); ++i)
  {
    // Is the feature eligible?
    if ((f = tar.features.find(ex.features[i].id)) != tar.features.end()
        && f->second.eligibility == eligible)
      tar.internalActivation += ex.features[i].strength * f->second.weight;
  }

  bool prediction = tar.internalActivation >= threshold
    + ((tar.externalActivation) ? globalParams.thickSeparator.positive
        : globalParams.thickSeparator.negative);

  // If there is a mistake, let the algorithm update the weights as in
  // classical Winnow.  If it's constraintClassification or it's interactive mode, 
  // the decision on when and how to update is made by the network, so don't do 
  // any updating here.
  if (!globalParams.constraintClassification 
      && globalParams.runMode != MODE_INTERACTIVE
      && globalParams.runMode != MODE_INTERACTIVESERVER)
  {
    if (tar.externalActivation != prediction)
    {
      if (globalParams.verbosity >= VERBOSE_MED)
        *globalParams.pResultsOutput << "Updating target (" << tar.targetID
                                     << ") for mistake...\n";
      // If we get to this point, then it isn't constraintClassification and a
      // mistake has been made.  If this target appeared in the current
      // example, then the mistake implies that promotion is needed.
      // Conversely, the absence of the target in this example implies
      // demotion.  Therefore, tar.externalActivation decides the update
      // method.
      Update(tar, ex, tar.externalActivation);
      return true;
    }
    else if (globalParams.gradientDescent)
    {
      Update(tar, ex, true);
      return true;
    }
  }

  return false;
}



// Updates the target based on the example and the Winnow parameters

// The decision on how to update has been moved out of the Update function,
// where it used to be decided by comparing tar.internalActivation with the
// threshold.  Now the decision is passed to the Update function as the third
// parameter.
void Winnow::Update( Target& tar, Example& ex, bool promote )
{
  int i;
  double multiplier;
  Target::FeatureMap::iterator f;

  multiplier = promote ? alpha : beta;
  if (!globalParams.gradientDescent && globalParams.threshold_relative
      && tar.internalActivation != 0)
  {

    multiplier *= threshold / tar.internalActivation;

    // Update the weight vector (no strength in threshold relative update).
    for (i = 0; i < ex.features.Size(); ++i)
    {
      if ((f = tar.features.find(ex.features[i].id)) != tar.features.end()
          && f->second.eligibility == eligible) 
      {

        f->second.weight *= multiplier;
        ++(f->second.updates);
      }
    }
  }
  else
  {
    if (globalParams.gradientDescent)
      multiplier = pow(alpha, tar.strength - tar.internalActivation);

    // Update the weight vector
    for (i = 0; i < ex.features.Size(); ++i)
    {
      
      if ((f = tar.features.find(ex.features[i].id)) != tar.features.end()
          && f->second.eligibility == eligible) 
      {
        f->second.weight *= pow(multiplier, ex.features[i].strength);
        ++(f->second.updates);
      }
    }
  }

  if (!tar.onlyTargetInCloud && tar.mistakes != -1)
    // Update the confidence of the target.  1 is added to tar.mistakes
    // because tar.mistakes isn't updated until after Winnow::PresentExample()
    // completes from within Target::PresentExample().
    tar.confidence /= 1 + CONFIDENCE_CONSTANT_A
                      / (CONFIDENCE_CONSTANT_B + tar.mistakes + 1);
}


/*
void Winnow::Discard( Target& tar )
{
  Target::FeatureMap::iterator feat = tar.features.begin();

  // Update the weight vector
  for ( ; feat != tar.features.end(); ++feat)
  {
    if ((globalParams.discardMethod == DISCARD_ABS)
        && (feat->second.weight < globalParams.discardThreshold))
      feat->second.discarded = discard;
  }
}
*/


void Winnow::SetTargetActivation( Target& tar, Example& ex )
{
  Target::FeatureMap::iterator f;

  tar.externalActivation = ex.HasTarget(tar.targetID);
  tar.internalActivation = 0.0;

  for (int i = 0; i < ex.features.Size(); ++i)
  {
    // Does this feature have a weight?
    if (((f = tar.features.find(ex.features[i].id)) != tar.features.end())
        && (f->second.eligibility == eligible))
      tar.internalActivation += ex.features[i].strength * f->second.weight;
    else
    {
      if (tar.FeatureIsLinkable(ex.features[i].id))
        tar.internalActivation -= ex.features[i].strength
                                  * globalParams.smoothing;
    }
  }
}


double Winnow::ReturnNormalizedActivation(Target& tar)
{
  double normalizedActivation = 
    tar.Confidence() / (1.0 + exp( threshold - tar.InternalActivation() ));
  return normalizedActivation;
}


void Winnow::PerformPercentageEligibility( Target& tar )
{
  map<int, int> featureHistogram;
  map<int, int>::iterator f;
  Target::FeatureMap::iterator it = tar.features.begin();
  Target::FeatureMap::iterator end = tar.features.end();
  int featureCount;

  // fill the histogram
  for (featureCount = 0; it != end; ++featureCount, ++it)
  {
    if ((f = featureHistogram.find(it->second.activeCount))
        != featureHistogram.end())
      ++(f->second);
    else featureHistogram[it->second.activeCount] = 1;
  }

  // find our desired feature count
  int eligibleFeatures = (int)((double)featureCount
                               * globalParams.eligibilityPercentage);

  // reset featureCount - it will now count the number of features with
  // activeCounts higher than our current position in the histogram
  featureCount = 0;

  f = featureHistogram.end();
  int eligibilityCutoff;

  for (; f != featureHistogram.begin() && featureCount < eligibleFeatures;
       --f)
    featureCount += f->second;
  eligibilityCutoff = f->first;

  // prune the network using our eligibilityCutoff 
  it = tar.features.begin();
  end = tar.features.end();

  for (; it != end; ++it)
  {
    if (it->second.activeCount < eligibilityCutoff)
      it->second.eligibility = pending;
  }
}


void Winnow::Show( ostream* out )
{
  *out << "Winnow: ("
       << setprecision(4) << alpha << ", "
       << setprecision(4) << beta << ", "
       << setprecision(4) << threshold << ", "
       << setprecision(4) << defaultWeight << ")";
  *out << " Targets: ";
  targetIds.Show(out);
  *out << endl;
}


void Winnow::Read( ifstream& in )
{
  in >> alpha >> beta >> threshold >> defaultWeight;
}


void Winnow::Write( ofstream& out )
{
  if (globalParams.verbosity >= VERBOSE_MED)
    Show(globalParams.pResultsOutput);

#ifdef WIN32
  // This looks weird, but it is a work around for the NT version.  Due to a
  // bug in MSVC 5.0 you have to call the insertion operator explicitly.
  operator<<(out, "winnow");

  out << ' ' << index << ' '
      << alpha << ' '
      << beta << ' ' 
      << threshold << ' '
      << defaultWeight << endl;
#else
  out << "winnow "
      << setprecision(10)
      << index << ' '
      << alpha << ' '
      << beta << ' '
      << threshold << ' '
      << defaultWeight << endl;
#endif
}

