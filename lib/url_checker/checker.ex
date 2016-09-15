defmodule URLChecker.Checker do
  def check(url, opts \\ []) do
    cache = opts[:cache] || Cache.Memory.new
    http  = opts[:http]  || HTTPotion

    Cache.write_through cache, url, [timestamp: opts[:timestamp], at_least: opts[:at_least]], fn ->
      result = fetch(url, http)

      cache_or_not = if cache?(result[:report][:status]), do: :cache, else: :dont_cache

      { cache_or_not, result }
    end
  end

  defp fetch(url, http) do
    response = http.get(
      url,
      follow_redirects: true,
      headers: ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"]
    )

    {return_status, report_status} = extract_status(response)
    message = extract_message(response)

    %{
      return: return_status,
      report: %{
        url: url,
        status: report_status,
        message: message
      }
    }
  end

  defp cache?(status) do
    status in 200..299 && status != 202
  end

  defp extract_status(%{ status_code: 202 }),         do: { 404, 202 }
  defp extract_status(%{ status_code: status_code }), do: { status_code, status_code }
  defp extract_status(%{ message: _ }),               do: { 404, 0 }

  defp extract_message(%{ message: message }), do: message
  defp extract_message(_), do: nil
end
