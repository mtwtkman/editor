from setuptools import setup


requirements = [
    'graphene-sqlalchemy',
    'pyramid',
    'pyramid_tm',
    'waitress',
    'webob-graphql',
    'zope.sqlalchemy',
    'alembic',
]

test_requires = [
    'pytest',
]


setup(
    name='editor',
    install_requires=requirements,
    test_require=test_requires,
    entry_points={
        'paste.app_factory': [
            'main = editor:main',
        ],
    },
)
