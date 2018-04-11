#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <argp.h>
#include <stdbool.h>

#define ARR_LENGTH      10000
#define NUM_BYTES       500

#define INSERTION            1
#define INDIRECT             2
#define SELECTION            3
#define SHELLSORT            4
#define TOO_MANY_OPTS_ERR   -1

typedef struct record {
    union {
        int value;
        char offset[NUM_BYTES];
    } key;
} record;

// information for argp
const char *argp_program_version = "largesort v0.2.0";
const char *argp_program_bug_address = "<aynrandjuggalo@gmail.com>";
static char doc[] = "largesort - sorts a large array with large records.";
static char args_doc[] = "";

static struct argp_option options[] = {
    {0, 'n', 0, 0, "Insertion sort" },
    {0, 'i', 0, 0, "Indirect insertion sort" },
    {0, 'S', 0, 0, "Shell sort" },
    {0, 's', 0, 0, "Selection sort" },
    { 0 }
};

struct arguments
{
    int sort_type;
};

static error_t parse_opt(int key, char *arg, struct argp_state *state)
{
    struct arguments *arguments = state->input;

    switch(key)
    {
        case 'n':
            if (!arguments->sort_type) {
                arguments->sort_type = INSERTION;
            } else {
                arguments->sort_type = TOO_MANY_OPTS_ERR;
            }
            break;
        case 'i':
            if (!arguments->sort_type) {
                arguments->sort_type = INDIRECT;
            } else {
                arguments->sort_type = TOO_MANY_OPTS_ERR;
            }
            break;
        case 's':
            if (!arguments->sort_type) {
                arguments->sort_type = SELECTION;
            } else {
                arguments->sort_type = TOO_MANY_OPTS_ERR;
            }
            break;
        case 'S':
            if (!arguments->sort_type) {
                arguments->sort_type = SHELLSORT;
            } else {
                arguments->sort_type = TOO_MANY_OPTS_ERR;
            }
            break;
        default:
            return ARGP_ERR_UNKNOWN;
    }

    return 0;
}   

static struct argp argp = { options, parse_opt, args_doc, doc };

void initialize_array(record a[]);

void insertion_sort(record a[]);
void insertion_sort_indirect(record a[]);
void shell_sort(record a[]);
void selection_sort(record a[]);

void sort(record a[], void (*s)(record a[]));
void crash(record a[]);

int main(int argc, char *argv[])
{
    int i, j;
    record a[ARR_LENGTH+1];
    void (*s)(record a[]);

    struct arguments arguments;
    arguments.sort_type = 0;
    
    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    srand(time(NULL));
    initialize_array(a);
    s = crash;
    
    if (arguments.sort_type == TOO_MANY_OPTS_ERR) {
        fprintf(stderr, "largesort: ambiguous sort algorithm specified.\n");
        return 2;
    } else if (!arguments.sort_type) {
        arguments.sort_type = INSERTION;
    }

    if (arguments.sort_type == INSERTION) {
        s = insertion_sort;
    } else if (arguments.sort_type == INDIRECT) {
        s = insertion_sort_indirect;
    } else if (arguments.sort_type == SHELLSORT) {
        s = shell_sort;
    } else if (arguments.sort_type == SELECTION) {
        s = selection_sort;
    }
    
    sort(a, s);

    // print out sorted array
    for (i = 1; i <= ARR_LENGTH; ++i) {
        printf("%3d\n", a[i].key.value);
    }

    return 0;
}

void initialize_array(record a[]) {
    int i;
  
    a[0].key.value = 0;

    for (i = 1; i <= ARR_LENGTH; ++i) {
        a[i].key.value = (rand() % 999) + 1;
    }
}

void sort(record a[], void (*s)(record a[])) {
    s(a);
}

void crash(record a[]) {
    fprintf(stderr, "largesort: internal error. Exiting...");
    exit(1);
}

void insertion_sort(record a[])
{
    int i, j;
    record temp;

    for (i = 2; i <= ARR_LENGTH; ++i) {
        temp = a[i];
        for (j = i; a[j - 1].key.value > temp.key.value; --j) {
            a[j] = a[j - 1];
        }
        a[j] = temp;
    }        
}

void insertion_sort_indirect(record a[])
{
    int i, j, t;
    int p[ARR_LENGTH+1];

    for (i = 0; i <= ARR_LENGTH; ++i) {
        p[i] = i;
    }

    for (i = 2; i <= ARR_LENGTH; ++i) {
        t = p[i];
        for (j = i; a[p[j-1]].key.value > a[t].key.value; --j) {
            p[j] = p[j-1];
        }
        p[j] = t;
    }

    int next, n;
    record temp;

    for (i = 1; i <= ARR_LENGTH; ++i) {
        if (p[i] != i) {
            temp = a[i];
            next = i;

            do {
                n = next;
                a[n] = a[p[n]];
                next = p[n];
                p[n] = n;
            } while (next != i);

            a[n] = temp;
        }
    }
}

void shell_sort(record a[])
{
    int i, j, h;
    record temp;

    for (h = 1; h <= ARR_LENGTH/9; h = (3*h)+1) {}
    for (; h > 0; h /= 3) {
        for (i = h+1; i <= ARR_LENGTH; ++i) {
            temp = a[i];
            for (j = i; j > h && a[j-h].key.value > temp.key.value; j -= h) {
                a[j] = a[j-h];
            }
            a[j] = temp;
        }
    }    
}

void selection_sort(record a[])
{
    int i, j, min;
    record temp;

    for (i = 1; i <= ARR_LENGTH - 1; ++i) {
        min = i;
        for (j = i+1; j <= ARR_LENGTH; ++j) {
            if (a[j].key.value < a[min].key.value) {
                min = j;
            }
        }
        temp = a[min]; a[min] = a[i]; a[i] = temp;
    }
}
