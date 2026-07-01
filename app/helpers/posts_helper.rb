module PostsHelper
  def post_month(post)
    post.display_date&.strftime("%b %Y")
  end

  def simple_post_body(body)
    return safe_post_html(body) if rich_text_body?(body)

    safe_join(
      body.to_s.split(/\n{2,}/).map do |paragraph|
        simple_format(paragraph, {}, wrapper_tag: "p")
      end
    )
  end

  def safe_post_html(body)
    sanitize(
      body.to_s.gsub(%r{<(script|style)\b[^>]*>.*?</\1>}im, ""),
      tags: %w[p div br strong em b i u h2 h3 blockquote ul ol li a code pre figure figcaption img],
      attributes: %w[href rel target src alt loading]
    )
  end

  def rich_text_body?(body)
    body.to_s.match?(/<\/?(p|div|br|strong|em|b|i|u|h2|h3|blockquote|ul|ol|li|a|code|pre|figure|figcaption|img)\b/i)
  end
end
