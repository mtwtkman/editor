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

tests_require = [
    'pytest',
    'pytest-only',
]

dev_require = [
    'mypy',
]


extras_require = {
    'test': tests_require,
    'dev': dev_require,
}

setup(
    name='edt',
    install_requires=requirements,
    tests_require=tests_require,
    extras_require=extras_require,
    entry_points={
        'paste.app_factory': [
            'main = edt:main',
        ],
    },
)
