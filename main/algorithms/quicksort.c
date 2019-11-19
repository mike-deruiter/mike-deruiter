/* quicksort - implementation of non-recursive quicksort */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#if __STDC_VERSION__ >= 199901L
#include <stdbool.h>
#else
typedef enum { false, true } bool;
#endif

#define N       25
#define MAX_VAL 99
#define MIN_VAL 1
#define SPACING 2

// stack data structure, functions, & variable
typedef struct {
    int *stack;
    int top;
} Stack;

Stack *init_stack(int size);
void push(Stack *s, int i);
int pop(Stack *s);
int peek(Stack *s);
bool stack_empty(Stack *s);

void init_array(int a[], int n);
void quicksort(int a[], int n);
void output_array(int a[], int l, int r);

int main()
{
    int a[N+1];

    init_array(a, N);
    quicksort(a, N);
    output_array(a, 1, N);

    return 0;
}

/* init_stack */
Stack *init_stack(int size) {
    Stack *s;

    s = malloc(sizeof(Stack));
    s->stack = malloc(size * sizeof(int));
    s->top = -1;

    return s;
}

/* push - push a value onto the stack. */
void push(Stack *s, int i) {
    s->stack[++s->top] = i;
}

/* pop - pop a value from the stack. */
int pop(Stack *s) {
    return s->stack[s->top--];
}

/* peek - return the value on top of the stack. */
int peek(Stack *s) {
    return s->stack[s->top];
}

bool stack_empty(Stack *s) {
    return s->top == -1 ? true : false;
}

void init_array(int a[], int n)
{
    int i;

    srand(time(NULL));

    a[0] = 0;

    for (i = 1; i <= n; ++i) {
        a[i] = (rand() % MAX_VAL) + MIN_VAL;
    }
}

void quicksort(int a[], int n)
{
    int p, i, j, l, r, t;
    int lo, mid, hi;
    Stack *stack;
    
    l = 1;  r = n;  stack = init_stack(N);
    //output_array(a, l, r);
    
    while (true) {   
        while (r > l) {
            //median-of-three partitioning
        	lo = l;  hi = r;  mid = (l + r) / 2;

	        if (a[mid] < a[lo]) {
	            t = a[mid];  a[mid] = a[lo];  a[lo] = t;
	        }
	        if (a[hi] < a[lo]) {
	            t = a[hi];  a[hi] = a[lo];  a[lo] = t;
	        }
	        if (a[hi] < a[mid]) {
	            t = a[hi];  a[hi] = a[mid];  a[mid] = t;
	        }

            t = a[mid];  a[mid] = a[hi];  a[hi] = t;
        
            p = a[r];  i = l-1;  j = r;

            while (true) {
                while (a[++i] < p);
                while (a[--j] > p);
    
                if (j < i) {
                    break;
                }
                
                //printf("%2d <-> %2d; ", a[i], a[j]);
                t = a[i];  a[i] = a[j];  a[j] = t;
            }
    
            //printf("%2d <-> %2d; ", a[i], a[r]);
            t = a[i];  a[i] = a[r];  a[r] = t;
            //putchar('\n');
    
            if (i-1 > r-i) {
                push(stack, l);    push(stack, i-1);  l = i+1;
            } else {
                push(stack, i+1);  push(stack, r);    r = i-1;
            }
        }
        
        if (stack_empty(stack)) {
            break;
        }
    
        r = pop(stack);  l = pop(stack);
    }
}

void output_array(int a[], int l, int r)
{
    int i;
 
    for (i = l; i <= r; ++i) {
        printf("%2d ", a[i]);
    }
 
    putchar('\n');
}
