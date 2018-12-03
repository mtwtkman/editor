import pytest

from edt.models import Article, Tag


@pytest.fixture(scope='class')
def article(request):
    request.self.article_data = [Article(title=f'title{i}', body=f'body{i}') for i in range(10)]
    request.self.session.add_all(request.self.article_data)


@pytest.fixture(scope='class')
def tag(request):
    request.self.tag_data = [Tag(name=f'tag{i}') for i in range(10)]
    request.self.session.add_all(request.cls.tag_data)
