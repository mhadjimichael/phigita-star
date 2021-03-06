/*===========================================================================*
 *                                                                           *
 *  calcul.cpp  Expression calculation function                              *
 *                                                                           *
 *  Written:    96/05/27    Antonnaux Pascal                                 *
 *  Revised:    96/05/28                                                     *
 *                                                                           *
 *  Skeleton generated by LIBERO 2.11 on 27 May, 1996, 21:07.                *
 *===========================================================================*/

#include "prelude.h"                    //  Public definitions
#include "calcul.h"                     //  Include prototypes

//  Definitions for the expression parser

#define end_mark_priority   1           //  Relative priority of tokens
#define left_par_priority   2           //    which may occur in exression
#define right_par_priority  3           //    - higher number means higher
#define term_op_priority    4           //    priority, ie. executed first.
#define factor_op_priority  5
#define power_op_priority   6
#define function_priority   6
#define lowest_op_priority  4

#define power_op_token      'P'         //  Indicates ** on operator stack
#define end_mark_token      'E'         //  Indicates end of operator stack
#define function_token      'F'         //  Indicates user-defined function


///////////////////////////   C O N T R U C T O R   ///////////////////////////

Ccalcul::Ccalcul (void)
{
    flist = NULL;
}


////////////////////////////   D E S T R U C T O R   //////////////////////////

Ccalcul::~Ccalcul (void)
{
    //  Free the function list
    Ccalc_fct
        *p_next;

    while (flist)
      {
        p_next = flist-> next;
        delete (flist);
        flist = p_next;
      }
}


//////////////////////////////////   M A I N   ////////////////////////////////

int Ccalcul::calculate (char *input, double *res, int *err_pos)
{
    if ( !input || !res || !err_pos )
        return (INVALID_TOKEN);

    feedback   = 0;                     //  Assume no errors
    expr       = input;
    result     = res;
    error_posn = err_pos;

#   include "calculd.i"                 //  Include dialog interpreter
}


Bool Ccalcul::add_function (func_i i, char *name)
{
    Bool
        rc = FALSE;
    Ccalc_fct
        *p_new;

    if (i == NULL || name == NULL )
        return (FALSE);
    p_new = new (Ccalc_fct);
    if (p_new)
      {
        p_new-> fct.i = i;
        p_new-> name  = new (char [strlen (name) + 1]);
        if (p_new-> name)
            strcpy (p_new-> name, name);
        p_new-> type = 'i';
        p_new-> next = flist;
        flist = p_new;
        rc    = TRUE;
      }

    return (rc);
}


Bool Ccalcul::add_function (func_l l, char *name)
{
    Bool
        rc = FALSE;
    Ccalc_fct
        *p_new;

    if (l == NULL || name == NULL )
        return (FALSE);
    p_new = new (Ccalc_fct);
    if (p_new)
      {
        p_new-> fct.l = l;
        p_new-> name  = new (char [strlen (name) + 1]);
        if (p_new-> name)
            strcpy (p_new-> name, name);
        p_new-> type = 'l';
        p_new-> next = flist;
        flist = p_new;
        rc    = TRUE;
      }

    return (rc);
}


Bool Ccalcul::add_function (func_d d, char *name)
{
    Bool
        rc = FALSE;
    Ccalc_fct
        *p_new;

    if (d == NULL || name == NULL )
        return (FALSE);
    p_new = new (Ccalc_fct);
    if (p_new)
      {
        p_new-> fct.d = d;
        p_new-> name  = new (char [strlen (name) + 1]);
        if (p_new-> name)
            strcpy (p_new-> name, name);
        p_new-> type = 'd';
        p_new-> next = flist;
        flist = p_new;
        rc    = TRUE;
      }

    return (rc);
}


Bool Ccalcul::add_function (func_s s, char *name)
{
    Bool
        rc = FALSE;
    Ccalc_fct
        *p_new;

    if (s == NULL || name == NULL )
        return (FALSE);
    p_new = new (Ccalc_fct);
    if (p_new)
      {
        p_new-> fct.s = s;
        p_new-> name  = new (char [strlen (name) + 1]);
        if (p_new-> name)
            strcpy (p_new-> name, name);
        p_new-> type = 's';
        p_new-> next = flist;
        flist = p_new;
        rc    = TRUE;
      }

    return (rc);
}

//////////////////////////   INITIALISE THE PROGRAM   /////////////////////////

MODULE Ccalcul::initialise_the_program (void)
{
    xptr = 0;                           //  Move to start of expression
    *result = 0;                        //  Assume result is zero
    *error_posn = 0;                    //  Default offset for errors
    operand_ptr  = 0;                   //  Operand stack holds zero
    operator_ptr = 0;                   //  Operator stack holds end mark
    operand_stack  [0].number   = 0;
    operand_stack  [0].type     = 'N';
    operator_stack [0].token    = end_mark_token;
    operator_stack [0].priority = end_mark_priority;

    the_next_event = ok_event;          //  Set ok
}


////////////////////////////   GET EXTERNAL EVENT   ///////////////////////////

MODULE Ccalcul::get_external_event (void)
{
}


//////////////////////////////   GET NEXT TOKEN   /////////////////////////////

MODULE Ccalcul::get_next_token (void)
{
    char
        *next;

    while (expr [xptr] == ' ') xptr++;
    token_posn = xptr;
    the_token = expr [xptr++];
    the_next_event = other_event;

    switch (the_token)
      {
        case '+':
        case '-':
            the_next_event = operator_event;
            the_priority   = term_op_priority;
            break;

        case '*':
            if (expr [xptr] == '*')
              {
                the_next_event = operator_event;
                the_priority   = power_op_priority;
                the_token      = power_op_token;
                xptr++;
                break;
              }                         //  if single '*', fall through
        case '/':
            the_next_event = operator_event;
            the_priority   = factor_op_priority;
            break;

        case '(':
            the_next_event = left_par_event;
            the_priority   = left_par_priority;
            break;

        case ')':
            the_next_event = right_par_event;
            the_priority   = right_par_priority;
            break;

        case '"':
            string_size = -1;
            do
              {
                the_token = expr [xptr++];
                if (the_token == '\0')
                  {
                    signal_error (QUOTES_EXPECTED);
                    break;
                  }
                the_string [++string_size] = the_token;
              } until (the_token == '"');
            the_string [string_size] = '\0';
            the_next_event = string_event;
            break;

        case '\0':
            the_next_event = end_mark_event;
            the_priority   = end_mark_priority;
            break;

        default:
            if (isdigit (the_token))
              {
                the_next_event = number_event;
                the_number = strtod (expr + xptr - 1, &next);
                xptr = (int) (next - expr);
                the_token = toupper (expr [xptr]);
                if (the_token == 'K')
                  {
                    the_number *= 1024.0;
                    xptr++;
                  }
                else
                if (the_token == 'M')
                  {
                    the_number *= 1048576.0;
                    xptr++;
                  }
              }
            else
            if (isalpha (the_token))
              {
                name_size = 0;
                while (isalnum (the_token))
                  {
                    if (name_size < name_max - 1)
                        the_name [name_size++] = toupper (the_token);
                    the_token = expr [xptr++];
                  }
                the_name [name_size] = '\0';
                the_next_event = function_event;
                the_priority   = function_priority;
                the_token      = function_token;
              }
            else
                signal_error (INVALID_TOKEN);
      }
}

void Ccalcul::signal_error (int error)
{
    feedback = error;
    raise_exception (exception_event);
}

///////////////////////////   SIGNAL INVALID TOKEN   //////////////////////////

MODULE Ccalcul::signal_invalid_token (void)
{
    feedback = INVALID_TOKEN;
}


///////////////////////////   SIGNAL TOKEN MISSING   //////////////////////////

MODULE Ccalcul::signal_token_missing (void)
{
    feedback = TOKEN_EXPECTED;
}


/////////////////////////////   STACK THE NUMBER   ////////////////////////////

MODULE Ccalcul::stack_the_number (void)
{
    stack_operand ('N', the_number);
}


void Ccalcul::stack_operand (char type, double value)
{
    if (operand_ptr < operand_max - 1)
      {
        operand_ptr++;
        operand_stack [operand_ptr].number = value;
        operand_stack [operand_ptr].type   = type;
      }
    else
        signal_error (OPERAND_OVERFLOW);
}


////////////////////////////   STACK THE OPERATOR   ///////////////////////////

MODULE Ccalcul::stack_the_operator (void)
{
    if (operator_ptr < operator_max - 1)
      {
        operator_ptr++;
        operator_stack [operator_ptr].token    = the_token;
        operator_stack [operator_ptr].priority = the_priority;
        strcpy (operator_stack [operator_ptr].name, the_name);
      }
    else
        signal_error (OPERATOR_OVERFLOW);
}


/////////////////////////////   STACK THE STRING   ////////////////////////////

MODULE Ccalcul::stack_the_string (void)
{
    stack_operand ('S', 0);
    operand_stack [operand_ptr].string = new char [string_max];
    strcpy (operand_stack [operand_ptr].string, the_string);
}


//////////////////////////   TERMINATE THE PROGRAM   //////////////////////////

MODULE Ccalcul::terminate_the_program (void)
{
    the_next_event = terminate_event;
    if (feedback)
        *error_posn = token_posn;
}


//////////////////////////   UNSTACK ALL OPERATORS   //////////////////////////

MODULE Ccalcul::unstack_all_operators (void)
{
    while (operator_stack [operator_ptr].priority >= lowest_op_priority)
        unstack_operator ();
}


///////////////////////////   UNSTACK GE OPERATORS   //////////////////////////

MODULE Ccalcul::unstack_ge_operators (void)
{
    while (operator_stack [operator_ptr].priority >= the_priority)
        unstack_operator ();
}


void Ccalcul::unstack_operator (void)
{
    cur_token = operator_stack [operator_ptr].token;
    strcpy (cur_name, operator_stack [operator_ptr--].name);

    op_1    = operand_stack [operand_ptr].number;
    op_type = operand_stack [operand_ptr].type;
    if (op_type == 'S')
      {
        strcpy (the_string, operand_stack [operand_ptr].string);
        delete (operand_stack [operand_ptr].string);
      }
    if ((cur_token == '+')
    ||  (cur_token == '-')
    ||  (cur_token == '*')
    ||  (cur_token == '/')
    ||  (cur_token == power_op_token))
      {
        op_2 = op_1;
        op_1 = operand_stack [--operand_ptr].number;
        require_number_op ();
      }

    switch (cur_token)
      {
        case '+':
            op_1 += op_2;
            break;
        case '-':
            op_1 -= op_2;
            break;
        case '*':
            op_1 *= op_2;
            break;
        case '/':
            op_1 /= op_2;
            break;
        case power_op_token:
            op_1 = pow (op_1, op_2);
            break;
        case end_mark_token:
            require_number_op ();
            *result = op_1;
            break;
        case function_token:
            execute_function ();
            break;
        default:
            cout << "!Error: Invalid operator " << cur_token << endl;
            exit (0);
      }
    operand_stack [operand_ptr].number = op_1;
    operand_stack [operand_ptr].type   = 'N';
}

void Ccalcul::require_number_op (void)
{
    if (op_type != 'N')
        signal_error (NUMBER_EXPECTED);
}

void Ccalcul::require_string_op (void)
{
    if (op_type != 'S')
      {
        signal_error (STRING_EXPECTED);
        strcpy (the_string, "");
      }
}

void Ccalcul::execute_function (void)
{
    Ccalc_fct
        *fptr;                          //  Pointer to possible functions
    char
        ftype;                          //  Function type
    Bool
        find = FALSE;

    fptr = flist;
    while (fptr)
      {
        if (fptr-> name     == NULL
        ||  fptr-> name [0] == '\0')
          {
            signal_error (UNKNOWN_FUNCTION);
            break;
          }
        if (streq (fptr-> name, cur_name))
          {
            find = TRUE;
            ftype = fptr-> type;
            if (ftype == 's')
                require_string_op ();
            else
                require_number_op ();

            switch (ftype)
              {
                case 'i': op_1 = (*fptr-> fct.i) ((int) op_1);  break;
                case 'l': op_1 = (*fptr-> fct.l) ((long) op_1); break;
                case 'd': op_1 = (*fptr-> fct.d) (op_1);        break;
                case 's': op_1 = (*fptr-> fct.s) (the_string);  break;
                default:
                    cout << "!Error: Invalid function type " << ftype << endl;
                    exit (0);
              }
            break;
        }
        fptr = fptr-> next;
      }
    if (!find)
        signal_error (UNKNOWN_FUNCTION);
}


///////////////////////////   UNSTACK IF END MARK   ///////////////////////////

MODULE Ccalcul::unstack_if_end_mark (void)
{
    if (operator_stack [operator_ptr].token == end_mark_token)
        unstack_operator ();
    else
        signal_error (RIGHT_PAR_EXPECTED);
}


///////////////////////////   UNSTACK IF LEFT PAR   ///////////////////////////

MODULE Ccalcul::unstack_if_left_par (void)
{
    if (operator_stack [operator_ptr].token == '(')
        operator_ptr--;
    else
        signal_error (LEFT_PAR_EXPECTED);
}

///  functions for class Ccalc_fct

Ccalc_fct::Ccalc_fct ()
{
    name  = NULL;
    type  =  ' ';
    next  = NULL;
    fct.i = NULL;
}

Ccalc_fct::~Ccalc_fct ()
{
    if (name)
        delete (name);
}
