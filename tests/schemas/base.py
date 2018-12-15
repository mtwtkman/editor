class CallFunc:
    def _callFUT(self, q):
        from edt.schemas import schema as testFunc
        return testFunc.execute(q)

    def t(self, tags):
        return f'''[{','.join([f'{{name: "{t}"}}' for t in tags])}]'''

    def q(
        self,
        id_=None,
        title=None,
        body=None,
        tags=None,
        fields=['id', 'title', 'body', 'published', 'createdAt'],
    ):
        assert title or body
        id_arg = f'id: {id_}, ' if id_ else ''
        title_arg = f'title: "{title}"' if title else ''
        body_arg = f'body: "{body}"' if body else ''
        article_arg = f'''article: {{{','.join([title_arg, body_arg])}}}'''
        tags_arg = f', tags: {self.t(tags)}' if tags else ''
        fields = '\n'.join(fields)
        return f'''
        mutation test {{
            {self.meth}({id_arg}{article_arg}{tags_arg}) {{
                {fields}
            }}
        }}
        '''
