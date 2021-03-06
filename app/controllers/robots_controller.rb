class RobotsController < ShikimoriController
  def anime_online
    render plain: <<~ROBOTS
      User-agent: *
      Disallow: /
    ROBOTS
  end

  def shikimori
    if ru_host?
      shikimori_ru
    else
      shikimori_en
    end
  end

  def shikimori_ru
    render plain: <<~ROBOTS
      User-agent: *
      Disallow: /*?
      Disallow: /*?rel=nofollow
      Disallow: /cosplay/*
      Disallow: /genres
      Disallow: /animes/*rss
      Disallow: /animes/order-by/*
      Disallow: /mangas/*rss
      Disallow: /mangas/order-by/*
      Disallow: /animes/search/*
      Disallow: /mangas/search/*
      Disallow: /*/comments
      Disallow: /*/tooltip
      Disallow: /*/autocomplete
      Disallow: /*/autocomplete/v2
      Disallow: /groups/9-Hentai*
      Disallow: /messages/*
      Disallow: /*undefined
      Disallow: /api/*
      Disallow: /*.html
      Host: https://shikimori.org
      Sitemap: https://shikimori.org/sitemap.xml

      User-agent: AhrefsBot
      User-agent: moget
      User-agent: ichiro
      User-agent: NaverBot
      User-agent: Yeti
      User-agent: Baiduspider
      User-agent: Baiduspider-video
      User-agent: Baiduspider-image
      User-agent: sogou spider
      User-agent: YoudaoBot
      User-agent: Yahoo Pipes 1.0
      User-agent: Yahoo Pipes 2.0
      Disallow: /
    ROBOTS
  end

  def shikimori_en
    render plain: <<~ROBOTS
      User-agent: *
      Disallow: /
    ROBOTS
  end
end
