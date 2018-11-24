from pyramid.view import view_config
import graphene
from webob_graphql import serve_graphql_request


class Query(graphene.ObjectType):
    hello = graphene.String(name=graphene.String(default_value='World'))

    def resolve_hello(self, info, name):
        return f'Hello {name}'


schema = graphene.Schema(query=Query)


@view_config(route_name='index')
def index(request):
    context = {'name': 'hoge'}
    return serve_graphql_request(request, schema, context_value=context)
