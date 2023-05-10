%{
#include <bits/stdc++.h>
#define MAX_SIZE 100
typedef struct my_var
{
    int type;
    char* variable_name;

}MY_VAR;
//MY_VAR variable_array[MAX_SIZE]; Array of variables
std::vector<MY_VAR> variable_vector;
std::vector<std::string> error_messages;
int my_index = 0;
void yyerror(char *s);
int yylex();

void setDataType(int t, char *var);
void displayVariables();
void printErrors();
int getVariableType(char *x);
int isNumeric(char *s);
int isCharacter(char *s);
int isFloat(char *s);
int validTypes(char *assignment);
int validOperation(char *operand1, char *operand2, int operation_type);
%}
%union {int a; char* c;}
%start begin
%token id numeric floating INT FLOAT CHAR INCLUDE MAIN VOID ARGCS QUOTE
%left '+' '-'
%left '*' '/' '%'
%type <a> datatype INT FLOAT CHAR
%type <c> id numeric term exp character floating
%%
begin : Headers MAIN '(' args ')' '{' line '}'           {displayVariables(); printErrors();}
     ;

Headers : '#' INCLUDE '<' header_name '>'            
        | Headers '#' INCLUDE '<' header_name '>'    
        ;

header_name : id '.' id
            ;
args : VOID 
     | ARGCS
     |
     ;

line : declaration ';'      {/*printf("variable declared successfully\n");*/}
     | line declaration ';' {/*printf("variable declared successfully\n");*/}
     | assignment ';'       {/*printf("Assignment\n");*/}
     | line assignment ';'  {/*printf("Assignment\n");*/}
     | empty_program        {/*printf("WOW SUCH EMPTY!");*/}
     ;
     
empty_program : ;   

declaration : datatype id   { setDataType($1, $2); }
            ;
datatype : INT      {$$ = 1;}
         | FLOAT    {$$ = 2;}
         | CHAR     {$$ = 3;}
         ;                
assignment : id '=' exp     {   if(!validTypes($1)){ yyerror("Types dont match!"); }   }
           ;
exp : exp '+' exp           { if(!validOperation($1, $3, 0)){ } }
    | exp '-' exp           { if(!validOperation($1, $3, 1)){ } }
    | exp '*' exp           { if(!validOperation($1, $3, 2)){ } }
    | exp '/' exp           { if(!validOperation($1, $3, 3)){ } }
    | exp '%' exp           { if(!validOperation($1, $3, 4)){ } }
    | term          { 
                        if(!isNumeric($1) && !getVariableType($1)){
                            //printf("%s", $1); 
                            if(isCharacter($1)){
                                break;
                            }
                            if(isFloat($1)){
                                break;
                            }
                            yyerror("Variable Not declared!\n");  
                        }else{
                            $$ = $1;
                        } 
                    }
    ;
term : id       {$$ = $1;}
     | numeric  {$$ = $1;}
     | floating    {$$ = $1;}
     | character {$$ = $1;}
     ;
character : QUOTE id QUOTE {char temp[4]; temp[0] = '\''; temp[1] = $2[0]; temp[2] = '\''; temp[3] = '\0'; $$ = temp;}
          | QUOTE numeric QUOTE {char temp[4]; temp[0] = '\''; temp[1] = $2[0]; temp[2] = '\''; temp[3] = '\0'; $$ = temp;}  
          ;                
%%
int main(void)
{
    yyparse();
    return 0;
}
void setDataType(int t, char *var)
{

        MY_VAR mv;
        mv.type = t;
        mv.variable_name = new char[strlen(var) + 1];
        strcpy(mv.variable_name, var);
        variable_vector.push_back(mv);
        my_index++;
    
}
void displayVariables()
{

    std::vector<MY_VAR>::iterator j;
    for(j = variable_vector.begin(); j != variable_vector.end(); ++j)
    {
        switch((*j).type)
        {
            case 1: printf("Variable: %s type 'int'\n", (*j).variable_name); break;
            case 2: printf("Variable: %s type 'float'\n", (*j).variable_name); break;
            case 3: printf("Variable: %s type 'char'\n", (*j).variable_name); break;
        }
    }
}
int getVariableType(char *x)
{
    std::vector<MY_VAR>::iterator it;
    int flag = 0;
    for(it = variable_vector.begin(); it!=variable_vector.end(); ++it)
    {
        if(strcmp((*it).variable_name, x) == 0){
            flag = (*it).type;
            break;
        }
    }
    return flag;
}
int isNumeric(char *s)
{
    int flag = 1;
    int i;
    for(i = 0; i < strlen(s); i++)
    {
        if(s[i] < '0' || s[i] > '9'){
            flag = 0;
            break;
        }
    }
    return flag;
}
int isCharacter(char *s){
    if(s[0] == '\'' && s[2] == '\''){
        return 1;
    }else{
        return 0;
    }
}
int isFloat(char *s){
    int flag = 0;
    int i = 0;
    while(i < strlen(s) && !flag){
        if(s[i] == '.'){
            flag = 1;    
        }
        i++;
    }
    return flag;
}
int validTypes(char *assignment){
   
    //printf("Entered: %s\n", assignment);
    int i, j = 0;
    char temp_id[10];
    char temp_exp[50];
    for(i = 0; i < strlen(assignment); i++){
        if(assignment[i] == '='){
            break;
        }
        if(assignment[i] == ' '){
            continue;
        }
        temp_id[j] = assignment[i];
        j++;
    }
    temp_id[j] = '\0';
    //printf("temp_id = %s\n", temp_id);
    i++; // Start of rest of the expression
    j = 0;
    while(assignment[i] != ';'){
        if(assignment[i] == ' '){
            i++;
        }else{
            temp_exp[j] = assignment[i];
            j++;
            i++;
        }    
    }
    temp_exp[j] = '\0';
    //printf("temp_exp = %s\n", temp_exp);

    int my_id_type = getVariableType(temp_id);
    int my_exp_type = getVariableType(temp_exp);

    if(my_id_type == my_exp_type){
        return 1;
    } else{
        if(my_id_type == 1 && my_exp_type == 2){ // Can't assign float to int
            return 0;
        }else if(my_id_type == 2 && my_exp_type == 3){ // Cant assign char to float
            return 0;
        }else if(my_id_type == 3 && my_exp_type == 2){ // Can't assign float to char
            return 0;
        }else{
            return 1;
        }
    }

}

int validOperation(char *operand1, char *operand2, int operation_type)
{
    /*switch(operation_type){
        case 0: printf("Operand 1: %s Operand 2: %s Operation: '+'\n", operand1, operand2); break;
        case 1: printf("Operand 1: %s Operand 2: %s Operation: '-'\n", operand1, operand2); break;
        case 2: printf("Operand 1: %s Operand 2: %s Operation: '*'\n", operand1, operand2); break;
        case 3: printf("Operand 1: %s Operand 2: %s Operation: '/'\n", operand1, operand2); break;
        case 4: printf("Operand 1: %s Operand 2: %s Operation: '\%'\n", operand1, operand2); break;
    }*/
    return 0;
}

void yyerror(char *s){
    std::string message_in_string(s);
    error_messages.push_back(s);
}

void printErrors(){
    std::vector<std::string>::iterator it;
    for(it = error_messages.begin(); it != error_messages.end(); ++it){
        std::cout << (*it) << std::endl;
    }
}
