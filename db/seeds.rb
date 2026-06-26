posts = [
  {
    title: "把个人站当成长期作品，而不是一次性简历",
    slug: "personal-site-as-a-long-term-project",
    excerpt: "关于持续更新、项目记录和内容结构。",
    body: <<~BODY,
      个人站不必一次完成。更好的方式，是把它当成一个持续生长的作品：每次完成一个项目、写下一段经验、修正一个页面，它都更接近你真实的工作方式。

      我希望这个站点记录的不只是结果，也包括过程里的选择：为什么做、怎么判断优先级、哪些方案被放弃，以及下一步准备改什么。
    BODY
    status: "published",
    published_at: Time.zone.parse("2026-06-01 10:00")
  },
  {
    title: "从零开始整理自己的开发工作流",
    slug: "organizing-my-development-workflow",
    excerpt: "终端、笔记、自动化脚本和复盘节奏。",
    body: <<~BODY,
      一个顺手的工作流，通常不是一次性设计出来的，而是在真实项目里反复磨出来的。

      我会优先整理三个层面：能快速开始工作的环境、能留下上下文的记录方式，以及能减少重复动作的小工具。它们不需要复杂，但要稳定。
    BODY
    status: "published",
    published_at: Time.zone.parse("2026-05-12 09:30")
  },
  {
    title: "一个小产品上线前，我会检查什么",
    slug: "preflight-checks-before-shipping",
    excerpt: "稳定性、文案、边界状态和用户路径。",
    body: <<~BODY,
      小产品上线前，我最关心的不是功能列表有多长，而是核心路径是否清楚、失败状态是否可理解、用户是否知道下一步该做什么。

      检查清单里会包括空状态、错误提示、移动端布局、性能、表单校验、SEO 信息，以及一个最重要的问题：这个版本是否真的能帮用户完成一件事。
    BODY
    status: "draft"
  },
  {
    title: "Rails 后端服务里，我如何划分业务边界",
    slug: "rails-backend-service-boundaries",
    excerpt: "从 controller、model、service object 到后台任务的取舍。",
    body: <<~BODY,
      Rails 的优势是约定清晰，很多功能可以很快落到 controller、model 和 view 里。但项目变大之后，真正影响可维护性的不是文件夹有多少，而是业务边界是否清楚。

      我通常会先让 controller 保持薄一些：接收参数、调用明确的业务入口、处理响应。model 负责和数据强相关的校验、状态流转、scope，以及那些离开数据上下文就不好理解的领域行为。

      当一个流程跨越多个模型，或者包含外部服务、事务、后台任务这些协作时，我会把它提成 service object。这个对象不需要为了抽象而抽象，它只要把一条业务路径命名清楚，让调用者知道“我要完成什么”。

      后台任务适合处理不需要同步返回的事情，比如发送通知、生成报表、同步第三方数据。这里最重要的是幂等性：任务可能重试，队列可能重复投递，所以任务执行多次也应该保持结果可控。

      一个 Rails 后端是否稳定，很多时候取决于边界是不是朴素。controller 不偷偷做业务，model 不承担整个世界，service 不变成万能脚本，job 不假设自己永远只跑一次。
    BODY
    status: "published",
    published_at: Time.zone.parse("2026-06-14 10:00")
  },
  {
    title: "Active Record 建模时我会优先检查的几件事",
    slug: "active-record-modeling-checklist",
    excerpt: "索引、唯一性、状态字段、scope 和数据完整性。",
    body: <<~BODY,
      Active Record 让数据库操作非常顺手，但也容易让人忽略数据模型本身的约束。我的习惯是先从查询路径倒推表结构：哪些字段会被频繁过滤，哪些字段会被排序，哪些关联需要预加载。

      如果业务上要求唯一，比如用户邮箱、文章 slug、订单号，我会同时写 Rails validation 和数据库 unique index。validation 提供更友好的错误信息，数据库约束负责兜底，二者解决的是不同层面的可靠性。

      状态字段要尽量少而明确。比如 draft、published、archived 这样的状态适合用字符串或枚举表达，但每个状态应该有清楚的进入条件和退出条件。状态切换最好集中在模型方法里，而不是散落在 controller 和 job 里。

      scope 适合表达会复用的查询语义，例如 published、recent_first、active。好的 scope 读起来像业务语言，而不是一段临时拼出来的 SQL 条件。

      最后我会看迁移里的索引是否匹配真实读取路径。很多 Rails 性能问题并不是框架慢，而是数据增长以后，原本没有成本感的查询突然变成了全表扫描。
    BODY
    status: "published",
    published_at: Time.zone.parse("2026-06-10 09:30")
  },
  {
    title: "用 Golang 写接口服务时，我最在意的三个细节",
    slug: "golang-api-service-details",
    excerpt: "context、超时、错误返回和并发边界。",
    body: <<~BODY,
      Go 很适合写接口服务，因为它的并发模型直接、部署形态简单、运行时开销稳定。但越是直接的工具，越需要在工程习惯上保持克制。

      第一个细节是 context。一次请求从进入服务开始，就应该携带可取消的上下文。访问数据库、调用下游接口、启动短生命周期 goroutine 时，都应该尊重这个 context，避免客户端已经断开，服务端还在继续消耗资源。

      第二个细节是超时。没有超时的网络调用是不完整的接口设计。对外部服务、缓存、数据库连接池都应该有明确的超时策略，否则局部抖动很容易扩散成整个服务不可用。

      第三个细节是错误返回。Go 的 error 很朴素，但接口层不能把内部错误原样丢给用户。我更倾向于在内部保留详细日志和 trace id，在外部返回稳定的错误码、可理解的信息，以及必要时的重试建议。

      Go 服务写得好不好，不只看 goroutine 用得多不多，而是看并发边界是否清晰、资源释放是否可靠、失败路径是否和成功路径一样被认真设计。
    BODY
    status: "published",
    published_at: Time.zone.parse("2026-06-06 11:00")
  },
  {
    title: "一次后端线上问题排查的基本顺序",
    slug: "backend-production-debugging-order",
    excerpt: "先确定影响面，再看指标、日志、变更和依赖。",
    body: <<~BODY,
      后端线上问题最怕一开始就猜原因。我的排查顺序通常是先确认影响面：哪些接口受影响，错误率是多少，是否只影响某一批用户、某个区域、某个版本或某个下游依赖。

      接着看指标。请求量、延迟、错误率、数据库连接、队列堆积、CPU 和内存，通常能帮助我们判断问题是流量变化、资源瓶颈、依赖异常，还是代码路径本身出了问题。

      然后看日志和 trace。日志不只是为了打印错误，而是为了还原上下文：请求参数的关键维度、用户或租户标识、下游请求耗时、异常堆栈、任务重试次数。trace id 可以把分散在多个服务里的线索串起来。

      再往后看最近变更。部署、配置、数据迁移、定时任务、第三方服务调整，都可能是触发点。这里不是为了归因给某一次改动，而是为了快速找到可回滚或可缓解的抓手。

      真正有效的排障不是一次英雄式操作，而是一套可重复的流程：定位影响面，找到止血方式，恢复服务，然后补上监控、测试和文档，让同类问题下次更早暴露。
    BODY
    status: "draft"
  }
]

posts.each do |attributes|
  post = Post.find_or_initialize_by(slug: attributes[:slug])
  post.update!(attributes)
end

photos = [
  {
    title: "城市黄昏",
    slug: "city-evening",
    description: "傍晚的楼宇和街灯，适合放在相册开头作为城市记录。",
    image_url: "https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80",
    location: "City",
    taken_on: Date.new(2026, 5, 22),
    featured: true,
    published: true
  },
  {
    title: "海边步道",
    slug: "seaside-walk",
    description: "一次短途旅行里拍下的海边步道，画面安静，颜色也很适合当前站点。",
    image_url: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80",
    location: "Seaside",
    taken_on: Date.new(2026, 4, 18),
    featured: true,
    published: true
  },
  {
    title: "工作台一角",
    slug: "desk-corner",
    description: "后端开发日常的一角：电脑、笔记和一杯咖啡。",
    image_url: "https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80",
    location: "Workspace",
    taken_on: Date.new(2026, 3, 8),
    featured: false,
    published: true
  },
  {
    title: "山路",
    slug: "mountain-road",
    description: "周末离开屏幕时拍下的山路。写代码之外，也需要给脑子留一点空白。",
    image_url: "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=80",
    location: "Mountain",
    taken_on: Date.new(2026, 2, 16),
    featured: false,
    published: true
  },
  {
    title: "雨后街道",
    slug: "after-rain-street",
    description: "雨后的路面反光，让普通街道也多了一点层次。",
    image_url: "https://images.unsplash.com/photo-1519608487953-e999c86e7455?auto=format&fit=crop&w=1200&q=80",
    location: "Street",
    taken_on: Date.new(2026, 1, 12),
    featured: false,
    published: true
  },
  {
    title: "未发布的照片草稿",
    slug: "hidden-photo-draft",
    description: "用于测试后台隐藏状态的照片草稿。",
    image_url: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80",
    location: "Draft",
    taken_on: Date.new(2025, 12, 20),
    featured: false,
    published: false
  }
]

photos.each do |attributes|
  photo = Photo.find_or_initialize_by(slug: attributes[:slug])
  photo.update!(attributes)
end
