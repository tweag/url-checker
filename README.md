# URL Checker

A web service for checking if a URL is publicly available.
It caches results to speed up your scripts and build processes that want to ensure links aren't 404ing.

It works with existing URL checking scripts (like [HTMLProofer][html-proofer]) by proxying the status code.

## How to use it

Instead of your script checking if http://example.com is 404ing, check if https://pw-url-checker.herokuapp.com/check?url=http://example.com is 404ing.

The status code of the response will be the same status code as it gets from the site.

It will return JSON that looks like this:

```json
{
  "url": "http://google.com",
  "status": 200,
  "message": null
}
```

* `url`: the url you checked
* `status`: the actual status that was returned by the url we checked.
  If the original site has a status of 0 or 202, URL checker will have a status of 404.
* `message`: any special error message that was encountered, like DNS errors.

It only caches the result if the status code is 200 through 299, but not 202.
That way, it can re-check if a website comes back up.

## Parameters

### `url`: URL, required

The URL to check.

### `timestamp`: Float/Int, optional but recommended

If the URL is checked and the result gets cached, the cache entry is marked with this timestamp.
If the URL does not need to be checked (i.e. a cached version is used), the cache entry is not updated.

**Recommendation: provide the current time in epoch time.**

### `at_least`: Float/Int, optional but recommended

If there is a cache entry for the given URL and its `timestamp` is greater than or equal to `at_least`, that cache entry will be returned.

If the parameter is not provided, any cache entry, no matter how old, will be considered valid.

**Recommendation: provide the oldest acceptable cache entry timestamp in epoch time.**

### Examples

#### 13 days example
If you want to cache results for 13 days, set `timestamp` to `Time.now.to_i` and `at_least` to `Time.to_i - 13*24*60*60`

#### Year example
If you want to cache results for 1 year, you would could set `timestamp` to `Date.today.year` and `at_least` to `Data.today.year - 1`

## Development tips

- Make sure Redis is running

## Deployment

Currently deployed on Heroku at https://pw-url-checker.herokuapp.com/

[html-proofer]: https://github.com/gjtorikian/html-proofer
