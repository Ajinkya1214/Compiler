struct symrec
    {
        char* name;
        int addr;
        int flag ;
        int inside;
        struct symrec * next;
    };

struct symrec *putsym (char*,char*);
struct symrec *getsym (char*);
char* getname(char* x);
struct symrec * sym_table = NULL;
int Adr = 0;

struct symrec * putsym(char* name, char* typ)
{
    struct symrec *ptr;
    ptr = malloc(sizeof(struct symrec));
    ptr->flag=0;
    ptr->inside=0;
    ptr->next = sym_table;
    sym_table = ptr;

    ptr->name = malloc(sizeof(char)*(strlen(name)+1));
    strcpy(ptr->name,name);
    // if(strcmp(typ,"FUNC")==0)
    // {
    //     ptr->flag = 1;
    //     return ptr;
    // }
    ptr->addr = Adr;
    Adr += 4;
    return ptr;
}

struct symrec * getsym(char* name)
{
    struct symrec *temp = sym_table;
    while(temp!=NULL)
    {  
        if(strcmp(temp->name,name)==0)return temp;
        temp = temp->next;
    }
    return 0;
}

