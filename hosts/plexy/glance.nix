{
  server = {
    host = "0.0.0.0";
    port = 15835;
  };
  theme = {
    light = false;
    background-color = "225 10 10";
    primary-color = "120 100 37";
    negative-color = "0 100 37";
    contrast-multiplier = 1.3;
  };
  pages = [
    {
      name = "Home";
      columns = [
        {
          size = "small";
          widgets = [
            {
              type = "calendar";
              hide-header = true;
            }
            {
              type = "rss";
              limit = 10;
              collapse-after = 3;
              cache = "20m";
              feeds = [
                {
                  url = "https://vitalik.eth.limo/feed.xml";
                }
                {
                  url = "https://blog.benjojo.co.uk/rss.xml";
                }
                {
                  url = "https://selfh.st/rss/";
                }
                {
                  url = "https://ersei.net/en/blog.atom";
                }
                {
                  url = "https://ersei.net/en/notes.atom";
                }
                {
                  url = "https://mbrizic.com/blog/feed.xml";
                }
                {
                  url = "https://samwho.dev/rss.xml";
                }
                {
                  url = "https://feeds.feedburner.com/martinkl";
                }
                {
                  url = "https://cocomelonc.github.io/feed.xml";
                }
                {
                  url = "https://www.da.vidbuchanan.co.uk/blog/rss.xml";
                }
                {
                  url = "https://kibty.town/blog.rss";
                }
                {
                  url = "https://textslashplain.com/feed";
                }
                {
                  url = "https://microsoftedge.github.io/edgevr/feed.xml";
                }
                {
                  url = "https://eieio.games/feed.xml";
                }
                {
                  url = "https://www.da.vidbuchanan.co.uk/blog/rss.xml";
                }
                {
                  url = "https://www.rugu.dev/en/index.xml";
                }
                {
                  url = "https://ericmigi.com/rss.xml";
                }
                {
                  url = "http://www.gridsagegames.com/blog/feed/";
                }
                {
                  url = "https://backdrifting.net/rss";
                }
                {
                  url = "https://env.fail/blog.rss";
                }
                {
                  url = "https://cblgh.org/articles.xml";
                }
                {
                  url = "https://cblgh.org/posts.xml";
                }
                {
                  url = "https://www.devever.net/~hl/index.feed";
                }
                {
                  url = "https://vit.baisa.cz/index.xml";
                }
                {
                  url = "https://chrismcleod.dev/follow/blog/feed.rss";
                }
                {
                  url = "https://www.winstoncooke.com/blog/atom.xml";
                }
                {
                  url = "https://conduition.io/rss2.xml";
                }
                {
                  url = "https://xeiaso.net/blog.rss";
                }
                {
                  url = "https://brycev.com/rss.xml";
                }
                {
                  url = "https://uptime.zen-browser.app/history.rss";
                }
                {
                  url = "https://endtimes.dev/feed.xml";
                }
                {
                  url = "https://shkspr.mobi/blog/feed/atom";
                }
                {
                  url = "https://www.evilsocket.net/atom.xml";
                }
                {
                  url = "https://bobdahacker.com/feed.xml";
                }
                {
                  url = "https://jorianwoltjer.com/blog/rss.xml";
                }
                {
                  url = "https://blog.jaisal.dev/rss.xml";
                }
                {
                  url = "https://planetscale.com/blog/feed.atom";
                }
                {
                  url = "https://lyra.horse/blog/posts/index.xml";
                }
                {
                  url = "https://jasonwryan.com/atom.xml";
                }
                {
                  url = "https://jvns.ca/atom.xml";
                }
                {
                  url = "https://zacoons.com/index.xml";
                }
                {
                  url = "https://notnite.com/blog/rss.xml";
                }
                {
                  url = "https://tonsky.me/atom.xml";
                }
                {
                  url = "https://heitorpb.github.io/atom.xml";
                }
                {
                  url = "https://precondition.github.io/feed.xml";
                }
                {
                  url = "https://www.adyxax.org/blog/index.xml";
                }
                {
                  url = "https://words.filippo.io/rss";
                }
                {
                  url = "https://yashgarg.dev/index.xml";
                }
              ];
            }
            {
              type = "twitch-channels";
              sort-by = "viewers";
              channels = [
                "dreamsofcode_dev"
                "tsoding"
                "sphaerophoria"
                "theprimeagen"
                "randy"
              ];
            }
          ];
        }
        {
          size = "full";
          widgets = [
            {
              type = "reddit";
              subreddit = "selfhosted";
            }
          ];
        }
        {
          size = "small";
          widgets = [
            {
              type = "weather";
              units = "metric";
              hour-format = "24h";
              location = "Tallinn Airport";
              hide-header = true;
            }
            {
              type = "releases";
              repositories = [
                "cloudflare/cloudflared"
                "dani-garcia/vaultwarden"
                "linkwarden/linkwarden"
                "glanceapp/glance"
                "codeberg:Forgejo/forgejo"
                "linuxserver/docker-qbittorrent"
                "jellyfin/jellyfin"
                "Fallenbagel/jellyseerr"
                "Radarr/Radarr"
                "Sonarr/Sonarr"
                "Prowlarr/Prowlarr"
              ];
            }
            {
              type = "custom-api";
              title = "Epic Games";
              cache = "1h";
              url = "https://store-site-backend-static.ak.epicgames.com/freeGamesPromotions?locale=en&country=US&allowCountries=US";
              template = "<div>
  {{ if eq .Response.StatusCode 200 }}
    <div class=\"horizontal-cards-2\">
      {{ range .JSON.Array \"data.Catalog.searchStore.elements\" }}
        {{ $price := .String \"price.totalPrice.discountPrice\" }}
        {{ $hasPromo := gt (len (.Array \"promotions.promotionalOffers\")) 0 }}
        {{ if and $hasPromo (eq $price \"0\") }}
          {{ $gamePage := .String \"productSlug\" }}
          {{ if gt (len (.Array \"offerMappings\")) 0 }}
            {{ $gamePage = .String \"offerMappings.0.pageSlug\" }}
          {{end }}
          <a href=\"https://store.epicgames.com/en-US/p/{{ $gamePage }}\" target=\"_blank\" class=\"card\">
            {{ $title := .String \"title\" }}
            {{ range .Array \"keyImages\" }}
              {{ if eq (.String \"type\") \"OfferImageWide\" }}
                <img src=\"{{ .String \"url\" }}\" alt=\"{{ $title }}\" style=\"width: 100%; max-width: 300px; height: 150px; object-fit: cover; border-radius: var(--border-radius);\">
              {{ end }}
            {{ end }}
            <div class=\"card-content\">
              <span class=\"size-base color-primary\">{{ $title }}</span><br>
              <span class=\"size-h5 color-subdue\">
                {{ if $hasPromo }}
                  {{ $promotions := .Array \"promotions.promotionalOffers\" }}
                  {{ if gt (len $promotions) 0 }}
                    {{ $firstPromo := index $promotions 0 }}
                    {{ $offers := $firstPromo.Array \"promotionalOffers\" }}
                    {{ if gt (len $offers) 0 }}
                      {{ $firstOffer := index $offers 0 }}
                      Free until {{ slice ($firstOffer.String \"endDate\") 0 10 }}
                    {{ else }}
                      Free this week!
                    {{ end }}
                  {{ else }}
                    Free this week!
                  {{ end }}
                {{ end }}
              </span>
            </div>
          </a>
        {{ end }}
      {{ end }}
    </div>
  {{ else }}
    <p class=\"color-negative\">Error fetching Epic Games data.</p>
  {{ end }}
</div> 
";
            }
          ];
        }
      ];
    }
  ];
}
