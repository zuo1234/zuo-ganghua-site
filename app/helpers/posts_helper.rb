module PostsHelper
  def post_month(post)
    post.display_date&.strftime("%b %Y")
  end

  def simple_post_body(body)
    safe_join(
      body.to_s.split(/\n{2,}/).map do |paragraph|
        simple_format(paragraph, {}, wrapper_tag: "p")
      end
    )
  end
end
