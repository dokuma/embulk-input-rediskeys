# Redis input plugin for Embulk

## Overview

* **Plugin type**: input
* **Resume supported**: yes
* **Cleanup supported**: yes
* **Guess supported**: no

## Configuration

- host: Redis hostname (string, default:localhost).
- port: Redis port number (int, default: 6379).
- db: Number of Redis DB to dump columns (int, default: 0).
- key_prefix: Prefix of column name to read (string, required).
- encode: Type of eoncoding of data to read (string, default:json).

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
