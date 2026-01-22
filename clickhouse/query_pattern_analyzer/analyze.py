#!/usr/bin/python3

import os
import sys
import re

try:
    import pandas as pd
except:
    print("Please install pandas using 'pip3 install pandas'")
    exit(1)

try:
    from pandarallel import pandarallel
except:
    print("Please install pandas using 'pip3 install pandarallel'")
    exit(1)

# use at most half of the cores by default
pandarallel.initialize(nb_workers=os.cpu_count() // 2, progress_bar=True)

try:
    import sqlparse
    from sqlparse.sql import Token, TokenList, Comment
except:
    print("Please install sqlparse using 'pip3 install sqlparse'")
    exit(1)

# excel supports at most 32768 characters for one cell, also enough for sql pattern
max_sql_pattern_length = 30000

ck_list_pattern = r'^\[([^,]+,\s*)*([^]]+)\]'

def replace_constants_with_placeholder(sql):
    sql = sql if len(sql) < max_sql_pattern_length else sql[:max_sql_pattern_length]

    parsed = sqlparse.parse(sql)
    statement = parsed[0]

    def replace_tokens(token_list):
        for token in token_list.tokens:
            if token.is_keyword or token.is_whitespace:
                continue
            elif token.ttype in (sqlparse.tokens.Literal.Number.Integer,
                               sqlparse.tokens.Literal.Number.Float,
                               sqlparse.tokens.Literal.String.Single):
                token.value = '?'
            elif token.ttype is None and token.value.startswith('[') and re.match(ck_list_pattern, token.value):
                token.value = re.sub(ck_list_pattern, '[?]', token.value)
                token.tokens = [Token(sqlparse.tokens.String, token.value)]
                continue
            elif isinstance(token, Comment):
                token.value = '/* COMMENT */ '
                # replace tokens to a single string token
                token.tokens = [Token(sqlparse.tokens.String, token.value)]
            elif isinstance(token, TokenList):
                replace_tokens(token)

    replace_tokens(statement)
    return str(statement)

def normalize_query(query):
    # unescape backslash encoded string
    # use latin-1 to ignore characters with incompatible encoding
    query = query.encode('latin-1', 'backslashreplace').decode('unicode-escape')

    # replace constant tokens with ?
    query = replace_constants_with_placeholder(query)

    # Replace `IN (x, y, z)` with `IN (?)`
    query = re.sub(r'\bin\s*\((\s|,|\?)*\)', 'IN (?)', query, flags=re.IGNORECASE)
    return query.replace('\n', '\\n').replace('\t', '\\t')

def aggregate_queries(file_path):
    global total
    # Read the tab-separated file
    df = pd.read_csv(file_path, sep='\t', encoding='latin-1')
    total = len(df.index)
    print("total queries: %d" % (total), file=sys.stderr)

    df = df.sample(frac=1) # shuffle for balanced parallel allocation

    # Parse queries to get query patterns
    df['query_pattern'] = df['query'].parallel_apply(normalize_query)
    print("\nall parsed", file=sys.stderr)

    # Aggregate duration_second, memory_usage, user_cpu and execution count by query pattern
    aggregation = df.groupby('query_pattern').agg({
        'duration_second': 'sum',
        'memory_usage': 'sum',
        'user_cpu': 'sum',
        'query_pattern': 'count'
    }).rename(columns={'query_pattern': 'execution_count'}).reset_index()

    # Sort by the most resource-consuming queries
    aggregation = aggregation.sort_values(by=['duration_second', 'memory_usage', 'user_cpu'], ascending=False)

    return aggregation

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: %s <query_log>", sys.argv[0])
        sys.exit(1)
    file_path = sys.argv[1]
    output_path = file_path + ".tsv"
    result = aggregate_queries(file_path)
    result.to_csv(output_path, index=False, sep="\t")
    print(result)
    print("\n[DONE] details in: " + output_path + "\n")