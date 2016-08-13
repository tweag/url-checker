defmodule LinkChecker.CheckController do
  use LinkChecker.Web, :controller

  def index(conn, %{ "url" => url } = params) do
    response = HTTPotion.get(url, follow_redirects: true)

    {return_status, report_status} = extract_status(response)
    message = extract_message(response)

    conn
    |> put_status(return_status)
    |> json %{ url: url, status: report_status, message: message }
  end

  defp extract_status(%{ status_code: 202 }),         do: { 404, 202 }
  defp extract_status(%{ status_code: status_code }), do: { status_code, status_code }
  defp extract_status(%{ message: _ }),               do: { 404, 0 }

  defp extract_message(%{ message: message }), do: message
  defp extract_message(_), do: nil
end
