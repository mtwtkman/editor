from unittest import TestCase
import os
from pathlib import Path

import transaction
from pyramid import testing
from sqlalchemy import engine_from_config
from pyramid.paster import get_appsettings

from edt.models import DBSession, Base


here = Path(os.path.dirname(__file__))
settings = get_appsettings(str(here / '..' / '..' / 'test.ini'))


class BaseTestCase(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.engine = engine_from_config(settings, prefix='sqlalchemy.')
        Base.metadata.create_all(cls.engine)
        DBSession.configure(bind=cls.engine)
        cls.session = DBSession

    @classmethod
    def tearDownClass(cls):
        Base.metadata.drop_all(cls.engine)

    def setUp(self):
        self.config = testing.setUp()

    def tearDown(self):
        for t in reversed(Base.metadata.sorted_tables):
            self.session.execute(t.delete())
        self.session.remove()
        testing.tearDown()
