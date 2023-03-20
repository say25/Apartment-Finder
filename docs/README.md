# Documentation

## Response Times

One of the data sources we use is <https://sightmap.com/>. We have noticed that response time is dramatically different depending on the time of the day. It appears they scale down their website every evening resulting in fewer cache hits.

| Time of Date (UTC) | Response Time (Avg) | Notes                                                             |
|--------------------|---------------------|-------------------------------------------------------------------|
| 14:00-03:00        | 180-300 ms          | There are occasion spikes to ~2 secs, presumably on cache updates |
| 03:00-14:00        | 1.5-3.0 secs        |                                                                   |
