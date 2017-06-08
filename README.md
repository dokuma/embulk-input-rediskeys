# Redis input plugin for Embulk

## Overview

* **Plugin type**: input
* **Resume supported**: yes
* **Cleanup supported**: yes
* **Guess supported**: no

## Configuration

- key_prefix: Prefix of column name to read (string, required).
- host: Redis hostname (string, default: localhost).
- port: Redis port number (int, default: 6379).
- db: Number of Redis DB to dump columns (int, default: 0).
- match_key_as_key: Use matche key for key (bool, default: true).
- encode: Type of eoncoding of data to read (string, default: json).
- colmuns: List of column name. Set match_key_as_key true, must be required(list, default: null).

Supported encode type are:

- json
- list
- hash

## Example

```yaml
in:
  type: rediskeys
  host: localhost
  port: 6379
  db: 0
  key_prefix: test_key
  encode: json
```


## Build

```
$ rake
```
