## [Unreleased]
## [0.4.4] - 2022-09-05
- "When we get an exception accessing the cache, return nil, not []
- Allow setting SQLite's busy_timout by env and default to 500, not 100
## [0.4.2] - 2022-08-22
- "More robust handling for CIDR - sometimes they're returned as x.x.x.x - y.y.y.y"

## [0.4.1] - 2022-08-22
- Honour `force` in DatacenterDetector#query

## [0.4.0] - 2022-08-05
- Store and retreive cache's hitrate.  
- Bug fixes
## [0.3.0] - 2022-08-05
- Store hit / miss data in sqlite to allow a hitrate score
- Handle response with no network found

## [0.2.0] - 2022-08-01

- Add a User Agent
- Update README
- Handle 127.0.0.1 as a special case

## [0.1.0] - 2022-08-01

- Initial release