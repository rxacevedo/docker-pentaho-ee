# docker-pentaho-ee

This is still a WIP.

## TODO

- [ ] Remove HSQLDB database/startup listener references from `web.xml`
- [ ] Only drop/create tables in DB if they don't already exist.
- [ ] Fix `SolutionContextListener.ERROR_0001 - Solution path is invalid` exception, this may be permissions-related. Current workaround is to hard-code it in, although this shouldn't be necessary.
