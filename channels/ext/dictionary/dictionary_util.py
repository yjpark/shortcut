import string

special_keys = """!@#$%^&*()',."<>/-=[];?_+{};`~\t\n"""
translate_table = string.maketrans(special_keys, '\t' * len(special_keys))

def parse_word(word):
    result = None
    if word:
        result = word.split('\n', 1)
        if result:
            result = result[0]
            if result:
                if isinstance(result, unicode):
                    result = result.encode('utf8')
                result = result.translate(translate_table)
                result = result.split('\t')
                if result:
                    result = ' '.join(result)
                    """
                    for _result in result:
                        if _result:
                            result = _result
                            break
                    """
    return result
