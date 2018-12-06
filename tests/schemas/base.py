class CallFunc:
    def _callFUT(self, q):
        from edt.schemas import schema as testFunc
        return testFunc.execute(q)
