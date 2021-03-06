glob = require 'glob'

module.exports =
  config:
    wallpaperFileGlob:
      title: 'Wallpaper Files (壁紙ファイル)'
      description: 'Set the wallpaper file in glob format. (壁紙ファイルをglob形式で設定します)'
      order: 10
      type: 'string'
      default: "#{process.env.HOME}/Pictures/**/*.?(png|jpg)"
    autoChangeIntervalSeconds:
      title: 'Automatic Switching Time (自動切替時間)'
      description: 'Set the time to switch automatically in seconds. (自動で切り替える時間を秒数で設定します)'
      order: 20
      type: 'integer'
      default: 1800
      minimum: 0
      maximum: 86400
    themeDarkOrLight:
      title: 'Wallpaper Brightness (壁紙の明るさ)'
      description: 'Select the brightness of the wallpaper. (壁紙の明るさを選択します)'
      order: 30
      type: 'string'
      default: 'auto'
      enum: [
        {value: 'auto', description: 'Auto Detect'}
        {value: 'dark', description: 'Dark'}
        {value: 'light', description: 'Light'}
      ]
    wallpaperSize:
      title: 'Wallpaper Size (壁紙の大きさ)'
      description: 'Sets the wallpaper size. (壁紙の大きさを設定します)'
      order: 40
      type: 'string'
      default: 'contain'
      enum: [
        {value: 'auto', description: 'Auto'}
        {value: 'cover', description: 'Cover'}
        {value: 'contain', description: 'Contain'}
        {value: '75%', description: '75%'}
        {value: '50%', description: '50%'}
        {value: '25%', description: '25%'}
      ]
    wallpaperRepeat:
      title: 'Wallpaper repeat (壁紙の繰り返し)'
      description: 'Sets the wallpaper repeat. (壁紙の繰り返しを設定します)'
      order: 50
      type: 'string'
      default: 'repeat'
      enum: [
        {value: 'no-repeat', description: 'No Repeat'}
        {value: 'repeat', description: 'Repeat All'}
        {value: 'repeat-x', description: 'Repeat X Only'}
        {value: 'repeat-y', description: 'Repeat Y Only'}
      ]
    darkColor:
      title: 'Dark Color (Dark色)'
      description: 'Set the Dark color. (Dark色を設定します)'
      order: 60
      type: 'color'
      default: 'rgba(30,30,30)'
    lightColor:
      title: 'Light Color (Light色)'
      description: 'Set the Light color. (Light色を設定します)'
      order: 70
      type: 'color'
      default: 'rgba(255,255,255)'
    wallpaperAlpha:
      title: 'Wallpaper Opacity (壁紙不透明度)'
      description: 'Set wallpaper opacity. (壁紙の不透明度を設定します)'
      order: 80
      type: 'number'
      default: 0.1
      minimum: 0
      maximum: 1
    highlightAlpha:
      title: 'Highlight Opacity (ハイライト不透明度)'
      description: 'Set highlight opacity. (ハイライトの不透明度を設定します)'
      order: 90
      type: 'number'
      default: 0.2
      minimum: 0
      maximum: 1
    selectorEdgeAlpha:
      title: 'Selected Area Boundary Opacity (選択領域境界不透明度)'
      description: 'Sets the opacity of the selection area boundary. (選択領域の境界の不透明度を設定します)'
      order: 100
      type: 'number'
      default: 0.7
      minimum: 0
      maximum: 1
    lineCursorAlpha:
      title: 'Line cursor Opacity (ラインカーソル不透明度)'
      description: 'Sets the opacity of the line cursor. (ラインカーソルの不透明度を設定します)'
      order: 110
      type: 'number'
      default: 0.05
      minimum: 0
      maximum: 1

  activate: ->
    @initVariables()
    @setCommands()
    @randomWallpaperEnable()

  deactivate: ->
    @randomWallpaperDisable()

  randomWallpaperEnable: ->
    @enable = true
    @insertWallpaper()
    @activateAutoChange()
    @hookUpdateConfig()

  randomWallpaperDisable: ->
    @enable = false
    @releaseUpdateConfig()
    @deactivateAutoChange()
    @removeWallpaper()

  toggle: ->
    if @enable
      @randomWallpaperDisable()
    else
      @randomWallpaperEnable()

  initVariables: ->
    #state
    @enable = false
    @hook_update_config =
      randomWallpaper: null
      theme: null
    @auto_change_interval_handle = null
    @inserted_styles =
      common: null
      wallpaper: null

    #dependence
    @glob = glob

    #config
    @settings = null
    @style = null
    @readConfig()

  readConfig: ->
    @settings =
      wallpaperFileGlob: atom.config.get('random-wallpaper.wallpaperFileGlob')
      autoChangeIntervalSeconds: atom.config.get('random-wallpaper.autoChangeIntervalSeconds')
      themeDarkOrLight: atom.config.get('random-wallpaper.themeDarkOrLight')

    if @settings.themeDarkOrLight == 'auto'
      @settings.themeDarkOrLight = 'dark'
      for theme_name in atom.themes.getActiveThemeNames()
        if theme_name.match(/light/i)
          @settings.themeDarkOrLight = 'light'

    dark_color = atom.config.get('random-wallpaper.darkColor')
    light_color = atom.config.get('random-wallpaper.lightColor')

    wallpaper_color = dark_color
    highlight_color = light_color

    if @settings.themeDarkOrLight != 'dark'
      wallpaper_color = light_color
      highlight_color = dark_color

    @style =
      wallpaper:
        alpha: 1.0 - atom.config.get('random-wallpaper.wallpaperAlpha')
        r: wallpaper_color.red
        g: wallpaper_color.green
        b: wallpaper_color.blue
        size: atom.config.get('random-wallpaper.wallpaperSize')
        repeat: atom.config.get('random-wallpaper.wallpaperRepeat')
      highlight:
        alpha: atom.config.get('random-wallpaper.highlightAlpha')
        r: highlight_color.red
        g: highlight_color.green
        b: highlight_color.blue
        edge_alpha: atom.config.get('random-wallpaper.selectorEdgeAlpha')
        line_cursor_alpha: atom.config.get('random-wallpaper.lineCursorAlpha')

  setCommands: ->
    atom.commands.add 'atom-workspace',
      "random-wallpaper:toggle": =>
        @toggle()

  hookUpdateConfig: ->
    @releaseUpdateConfig()
    @hook_update_config.randomWallpaper = atom.config.onDidChange 'random-wallpaper', (event) =>
      @readConfig()
      @insertWallpaper()
      @activateAutoChange()
    @hook_update_config.theme = atom.themes.onDidChangeActiveThemes =>
      @readConfig()
      @insertWallpaper()
      @activateAutoChange()

  releaseUpdateConfig: ->
    if @hook_update_config.randomWallpaper
      @hook_update_config.randomWallpaper.dispose()
      @hook_update_config.randomWallpaper = null
    if @hook_update_config.theme
      @hook_update_config.theme.dispose()
      @hook_update_config.theme = null

  changeWallpaper: ->
    if @settings.wallpaperFileGlob
      @glob @settings.wallpaperFileGlob, (err, files) =>
        if err
          console.log('wallpaper not found. : maybe wallpaperFileGlob-syntax-error')
          return
        path = if files then files[Math.floor(Math.random() * files.length) ] else null
        if path
          @inserted_styles.wallpaper = atom.styles.addStyleSheet(@generateWallpaperStyle(path), {
            sourcePath: 'muu/random-wallpaper-image'
          })

  insertWallpaper: ->
    @removeWallpaper()
    @changeWallpaper()
    atom.views.getView(atom.workspace).classList.add('random-wallpaper')
    @inserted_styles.common = atom.styles.addStyleSheet(@generateStyle(), {
      sourcePath: 'muu/random-wallpaper'
    })

  removeWallpaper: ->
    for key, style of @inserted_styles
      if style
        style.dispose()
        @inserted_styles[key] = null
    atom.views.getView(atom.workspace).classList.remove('random-wallpaper')

  activateAutoChange: ->
    @deactivateAutoChange()
    if @settings.autoChangeIntervalSeconds
      @auto_change_interval_handle = setInterval =>
        @changeWallpaper()
      , @settings.autoChangeIntervalSeconds * 1000

  deactivateAutoChange: ->
    if @auto_change_interval_handle
      clearInterval @auto_change_interval_handle
      @auto_change_interval_handle = null

  generateWallpaperStyle: (path) ->
    """
      .random-wallpaper {
        background-image: url(\"#{path}\") !important;
      }
    """

  generateStyle: ->
    """
      .random-wallpaper {
        background: #{@style.wallpaper.repeat} fixed center center / #{@style.wallpaper.size};
        transition: background 2s ease-in-out;
      }

      /* container */
      atom-panel-container,
      atom-panel-container.left,
      atom-panel-container.right,
      atom-panel-container.header,
      atom-panel-container.footer,
      atom-pane-container {
        background-image: none;
        background-color: rgba(#{@style.wallpaper.r}, #{@style.wallpaper.g}, #{@style.wallpaper.b}, #{@style.wallpaper.alpha});
      }
      atom-pane-container atom-pane,
      atom-panel-container atom-panel,
      atom-panel-container.header atom-panel,
      atom-panel-container.footer atom-panel,
      atom-panel-container.top atom-panel,
      atom-panel-container.bottom atom-panel,
      atom-panel-container.left atom-panel,
      atom-panel-container.right atom-panel,
      atom-panel-container.top .tool-panel,
      atom-panel-container.bottom .tool-panel,
      atom-panel-container.left .tool-panel,
      atom-panel-container.right .tool-panel,
      atom-panel-container.bottom header.header,
      atom-pane-container atom-pane .item-views .pane-item,
      atom-panel-container atom-panel .status-bar, /* for one-dark,light */
      atom-pane-container atom-pane .item-views,
      atom-pane-container atom-pane .pane-item {
        background-image: none;
        background-color: transparent;
      }

      /* editor */
      atom-text-editor {
        background-image: none;
        background-color: transparent;
      }
      atom-text-editor .gutter-container .gutter {
        background-image: none;
        background-color: transparent;
      }
      atom-text-editor .cursor-line,
      atom-text-editor .gutter-container .gutter .cursor-line {
        background-image: none;
        background-color: rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.line_cursor_alpha});
      }
      atom-text-editor .selection .region {
        background-image: none;
        background-color: rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.alpha});
        border-left: dotted 1px rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.edge_alpha});
        border-right: dotted 1px rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.edge_alpha});
      }

      /* settings */
      .settings-view .panels, /* for one-dark,light */
      .settings-view .panels .panels-item, /* for atom-material */
      .settings-view .config-menu /* for atom-dark,light */ {
        background-image: none;
        background-color: transparent;
      }
      .settings-view .panels .panels-item .package-card {
        background-image: none;
        background-color: rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.alpha});
      }

      /* dock */
      .atom-dock-mask {
        background-image: none;
        background-color: transparent;
      }
      .atom-dock-mask atom-pane-container {
        background-image: none;
        background-color: transparent;
      }

      /* tree-view */
      atom-dock .tree-view,
      .tree-view {
        background-image: none;
        background-color: transparent;
      }
      .focusable-panel {
        background-image: none;
        background-color: transparent;
      }

      /* tabs */
      .tab-bar {
        background-image: none;
        background-color: transparent;
      }
      .pane .tab-bar .tab .title, /* for one-dark,light */
      .pane .tab-bar .tab.active .title, /* for one-dark,light */
      .pane .tab-bar .tab {
        border:none;
        background-image: none;
        background-color: transparent;
      }
      .pane .tab-bar .tab.active {
        background-image: none;
        background-color: rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.alpha});
      }
      .tab::before, .tab::after, .tab-bar::after {
        /* for atom-dark,atom-light */
        display: none;
      }
      .tab > div {
        /* for atom-dark,atom-light */
        margin-left: 10px;
        margin-right: 10px;
      }

      /* scrollbar */
      .scrollbars-visible-always ::-webkit-scrollbar {
        //background: none;
      }
      .scrollbars-visible-always ::-webkit-scrollbar-track {
        background-image: none;
        background-color: transparent;
      }
      .scrollbars-visible-always ::-webkit-scrollbar-thumb {
        background-image: none;
        background-color: rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.alpha});
      }
      .scrollbars-visible-always ::-webkit-scrollbar-thumb:window-inactive {
        background-image: none;
        background-color: rgba(#{@style.highlight.r}, #{@style.highlight.g}, #{@style.highlight.b}, #{@style.highlight.alpha});
      }
      .scrollbars-visible-always ::-webkit-scrollbar-corner {
        background-image: none;
        background-color: transparent;
      }
    """
