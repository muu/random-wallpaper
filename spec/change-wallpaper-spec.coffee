# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.
RandomWallpaper = require '../lib/main'

describe "RandomWallpaper", ->

  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

  describe "Atom Workspace", ->

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('random-wallpaper')
      runs ->
        atom.config.set('random-wallpaper.commands', [])

    describe "when the random-wallpaper activated", ->
      it "is a success", ->
        expect(atom.packages.isPackageActive('random-wallpaper')).toBe(true)
      it "add random-wallpaper class to workspace", ->
        expect(workspaceElement.classList.contains('random-wallpaper')).toBe(true)

    describe "when the random-wallpaper:toggle event is triggered", ->
      it "toggle off random-wallpaper class to workspace", ->
        waitsFor ->
          atom.commands.dispatch workspaceElement, 'random-wallpaper:toggle'
        runs ->
          expect(workspaceElement.classList.contains('random-wallpaper')).toBe(false)
      it "toggle on random-wallpaper class to workspace", ->
        waitsFor ->
          atom.commands.dispatch workspaceElement, 'random-wallpaper:toggle'
        runs ->
          expect(workspaceElement.classList.contains('random-wallpaper')).toBe(false)
        waitsFor ->
          atom.commands.dispatch workspaceElement, 'random-wallpaper:toggle'
        runs ->
          expect(workspaceElement.classList.contains('random-wallpaper')).toBe(true)

  describe "class RandomWallpaper", ->

    describe "RandomWallpaper::activate", ->
      it "was processed", ->
        spyOn(RandomWallpaper,"initVariables")
        spyOn(RandomWallpaper,"setCommands")
        spyOn(RandomWallpaper,"randomWallpaperEnable")
        RandomWallpaper.activate()
        expect(RandomWallpaper.initVariables).toHaveBeenCalled()
        expect(RandomWallpaper.setCommands).toHaveBeenCalled()
        expect(RandomWallpaper.randomWallpaperEnable).toHaveBeenCalled()

    describe "RandomWallpaper::deactivate", ->
      it "was processed", ->
        spyOn(RandomWallpaper,"randomWallpaperDisable")
        RandomWallpaper.deactivate()
        expect(RandomWallpaper.randomWallpaperDisable).toHaveBeenCalled()

    describe "RandomWallpaper::randomWallpaperEnable", ->
      it "was processed", ->
        spyOn(RandomWallpaper,"insertWallpaper")
        spyOn(RandomWallpaper,"activateAutoChange")
        spyOn(RandomWallpaper,"hookUpdateConfig")
        RandomWallpaper.randomWallpaperEnable()
        expect(RandomWallpaper.enable).toBe(true)
        expect(RandomWallpaper.insertWallpaper).toHaveBeenCalled()
        expect(RandomWallpaper.activateAutoChange).toHaveBeenCalled()
        expect(RandomWallpaper.hookUpdateConfig).toHaveBeenCalled()

    describe "RandomWallpaper::randomWallpaperDisable", ->
      it "was processed", ->
        spyOn(RandomWallpaper,"releaseUpdateConfig")
        spyOn(RandomWallpaper,"deactivateAutoChange")
        spyOn(RandomWallpaper,"removeWallpaper")
        RandomWallpaper.randomWallpaperDisable()
        expect(RandomWallpaper.enable).toBe(false)
        expect(RandomWallpaper.releaseUpdateConfig).toHaveBeenCalled()
        expect(RandomWallpaper.deactivateAutoChange).toHaveBeenCalled()
        expect(RandomWallpaper.removeWallpaper).toHaveBeenCalled()

    describe "RandomWallpaper::toggle", ->
      it "was not processed", ->
        RandomWallpaper.enable = false
        spyOn(RandomWallpaper,"randomWallpaperDisable")
        spyOn(RandomWallpaper,"randomWallpaperEnable")
        RandomWallpaper.toggle()
        expect(RandomWallpaper.randomWallpaperDisable).not.toHaveBeenCalled()
        expect(RandomWallpaper.randomWallpaperEnable).toHaveBeenCalled()
      it "was processed", ->
        RandomWallpaper.enable = true
        spyOn(RandomWallpaper,"randomWallpaperDisable")
        spyOn(RandomWallpaper,"randomWallpaperEnable")
        RandomWallpaper.toggle()
        expect(RandomWallpaper.randomWallpaperDisable).toHaveBeenCalled()
        expect(RandomWallpaper.randomWallpaperEnable).not.toHaveBeenCalled()
      it "was toggled", ->
        RandomWallpaper.enable = false
        spyOn(RandomWallpaper,"randomWallpaperDisable")
        spyOn(RandomWallpaper,"randomWallpaperEnable")
        RandomWallpaper.toggle()
        RandomWallpaper.enable = true
        RandomWallpaper.toggle()
        expect(RandomWallpaper.randomWallpaperDisable).toHaveBeenCalled()
        expect(RandomWallpaper.randomWallpaperEnable).toHaveBeenCalled()

    describe "RandomWallpaper::initVariables", ->
      it "was processed", ->
        spyOn(RandomWallpaper,"readConfig")
        RandomWallpaper.initVariables()
        expect(RandomWallpaper.readConfig).toHaveBeenCalled()
        expect(RandomWallpaper.enable).toBe(false)
        expect(RandomWallpaper.hook_update_config.randomWallpaper).toBeNull()
        expect(RandomWallpaper.hook_update_config.theme).toBeNull()
        expect(RandomWallpaper.auto_change_interval_handle).toBeNull()
        expect(RandomWallpaper.inserted_styles.common).toBeNull()
        expect(RandomWallpaper.inserted_styles.wallpaper).toBeNull()
        expect(RandomWallpaper.glob).not.toBeNull()
        expect(RandomWallpaper.settings).toBeNull()
        expect(RandomWallpaper.style).toBeNull()

    describe "RandomWallpaper::readConfig", ->

      config = {}
      themes = []

      beforeEach ->
        config =
          'random-wallpaper.wallpaperFileGlob': "test1"
          'random-wallpaper.autoChangeIntervalSeconds': 1234
          'random-wallpaper.themeDarkOrLight': 'auto'
          'random-wallpaper.darkColor': { red: 1, green: 2, blue: 3 }
          'random-wallpaper.lightColor': { red: 4, green: 5, blue: 6 }
          'random-wallpaper.wallpaperAlpha': 0.1
          'random-wallpaper.highlightAlpha': 0.2
          'random-wallpaper.selectorEdgeAlpha': 0.3
        themes = ['UI Dark','Syntax Dark']
        spyOn(atom.config,"get").andCallFake (key) ->
          return config[key]
        spyOn(atom.themes,"getActiveThemeNames").andReturn(themes)

      afterEach ->
        atom.config.get.andCallThrough()
        atom.themes.getActiveThemeNames.andCallThrough()

      it "was processed (auto detect dark theme)", ->
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test1"
          autoChangeIntervalSeconds: 1234
          themeDarkOrLight: "dark"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.1, r: 1, g: 2, b: 3 }
          highlight: { alpha: 0.2,       r: 4, g: 5, b: 6 , edge_alpha: 0.3 }
        )
      it "was processed (auto detect light theme)", ->
        themes[0] = 'UI Light'
        themes[1] = 'Syntax Light'
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test1"
          autoChangeIntervalSeconds: 1234
          themeDarkOrLight: "light"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.1, r: 4, g: 5, b: 6 }
          highlight: { alpha: 0.2,       r: 1, g: 2, b: 3 , edge_alpha: 0.3 }
        )
      it "was processed (auto detect dark and light theme)", ->
        themes[0] = 'UI Dark'
        themes[1] = 'Syntax Light'
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test1"
          autoChangeIntervalSeconds: 1234
          themeDarkOrLight: "light"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.1, r: 4, g: 5, b: 6 }
          highlight: { alpha: 0.2,       r: 1, g: 2, b: 3 , edge_alpha: 0.3 }
        )
      it "was processed (manual set dark theme)", ->
        themes[0] = 'UI Light'
        themes[1] = 'Syntax Light'
        config["random-wallpaper.themeDarkOrLight"] = 'dark'
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test1"
          autoChangeIntervalSeconds: 1234
          themeDarkOrLight: "dark"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.1, r: 1, g: 2, b: 3 }
          highlight: { alpha: 0.2,       r: 4, g: 5, b: 6 , edge_alpha: 0.3 }
        )
      it "was processed (manual set light theme)", ->
        themes[0] = 'UI Dark'
        themes[1] = 'Syntax Dark'
        config["random-wallpaper.themeDarkOrLight"] = 'light'
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test1"
          autoChangeIntervalSeconds: 1234
          themeDarkOrLight: "light"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.1, r: 4, g: 5, b: 6 }
          highlight: { alpha: 0.2,       r: 1, g: 2, b: 3 , edge_alpha: 0.3 }
        )
      it "was processed (change glob pattern)", ->
        config["random-wallpaper.wallpaperFileGlob"] = "test2"
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test2"
          autoChangeIntervalSeconds: 1234
          themeDarkOrLight: "dark"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.1, r: 1, g: 2, b: 3 }
          highlight: { alpha: 0.2,       r: 4, g: 5, b: 6 , edge_alpha: 0.3 }
        )
      it "was processed (change interval seconds)", ->
        config["random-wallpaper.autoChangeIntervalSeconds"] = 9876
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test1"
          autoChangeIntervalSeconds: 9876
          themeDarkOrLight: "dark"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.1, r: 1, g: 2, b: 3 }
          highlight: { alpha: 0.2,       r: 4, g: 5, b: 6 , edge_alpha: 0.3 }
        )
      it "was processed (change alphas)", ->
        config['random-wallpaper.wallpaperAlpha'] = 0.4
        config['random-wallpaper.highlightAlpha'] = 0.5
        config['random-wallpaper.selectorEdgeAlpha'] = 0.6
        RandomWallpaper.readConfig()
        expect(RandomWallpaper.settings).toEqual(
          wallpaperFileGlob: "test1"
          autoChangeIntervalSeconds: 1234
          themeDarkOrLight: "dark"
        )
        expect(RandomWallpaper.style).toEqual(
          wallpaper: { alpha: 1.0 - 0.4, r: 1, g: 2, b: 3 }
          highlight: { alpha: 0.5,       r: 4, g: 5, b: 6 , edge_alpha: 0.6 }
        )


    describe "RandomWallpaper::setCommands", ->
      it "was processed", ->
        spyOn(atom.commands,"add").andCallFake (key, defines) ->
          expect(key).toBe('atom-workspace')
          expect(defines["random-wallpaper:toggle"]).toBeDefined()
        RandomWallpaper.setCommands()
        expect(atom.commands.add).toHaveBeenCalled()
        atom.commands.add.andCallThrough()

    describe "RandomWallpaper::hookUpdateConfig", ->
      it "was processed", ->
        spyOn(RandomWallpaper,"releaseUpdateConfig")
        spyOn(RandomWallpaper,"readConfig")
        spyOn(RandomWallpaper,"insertWallpaper")
        spyOn(RandomWallpaper,"activateAutoChange")
        spyOn(atom.config,"onDidChange").andCallFake (key, callback) ->
          expect(key).toBe("random-wallpaper")
          return "test-hook-1"
        spyOn(atom.themes,"onDidChangeActiveThemes").andCallFake () ->
          return "test-hook-2"
        RandomWallpaper.hookUpdateConfig()
        expect(RandomWallpaper.hook_update_config.randomWallpaper).toBe("test-hook-1")
        expect(RandomWallpaper.hook_update_config.theme).toBe("test-hook-2")
        expect(RandomWallpaper.releaseUpdateConfig).toHaveBeenCalled()
        expect(RandomWallpaper.readConfig).not.toHaveBeenCalled()
        expect(RandomWallpaper.insertWallpaper).not.toHaveBeenCalled()
        expect(RandomWallpaper.activateAutoChange).not.toHaveBeenCalled()
        expect(atom.config.onDidChange).toHaveBeenCalled()
        expect(atom.themes.onDidChangeActiveThemes).toHaveBeenCalled()
        atom.config.onDidChange.andCallThrough()
        atom.themes.onDidChangeActiveThemes.andCallThrough()

    describe "RandomWallpaper::releaseUpdateConfig", ->
      it "was not processed", ->
        RandomWallpaper.hook_update_config =
          randomWallpaper: null
          theme: null
        RandomWallpaper.releaseUpdateConfig()
        expect(RandomWallpaper.hook_update_config.randomWallpaper).toBeNull()
        expect(RandomWallpaper.hook_update_config.theme).toBeNull()
      it "was processed", ->
        RandomWallpaper.hook_update_config =
          randomWallpaper:
            dispose: ->
              "test"
          theme:
            dispose: ->
              "test"
        RandomWallpaper.releaseUpdateConfig()
        expect(RandomWallpaper.hook_update_config.randomWallpaper).toBeNull()
        expect(RandomWallpaper.hook_update_config.theme).toBeNull()

    describe "RandomWallpaper::changeWallpaper", ->
      it "was not processed", ->
        RandomWallpaper.settings.wallpaperFileGlob = null
        spyOn(RandomWallpaper,"glob")
        RandomWallpaper.changeWallpaper()
        expect(RandomWallpaper.glob).not.toHaveBeenCalled()
      it "was not processed (glob error)", ->
        RandomWallpaper.settings.wallpaperFileGlob = "test-pattern"
        spyOn(RandomWallpaper,"glob").andCallFake (pattern, callback) ->
          expect(pattern).toBe("test-pattern")
          callback("test-error")
        spyOn(atom.styles,"addStyleSheet")
        RandomWallpaper.changeWallpaper()
        expect(RandomWallpaper.glob).toHaveBeenCalled()
        expect(atom.styles.addStyleSheet).not.toHaveBeenCalled()
        RandomWallpaper.glob.andCallThrough()
      it "was processed", ->
        RandomWallpaper.settings.wallpaperFileGlob = "test-pattern"
        spyOn(RandomWallpaper,"glob").andCallFake (pattern, callback) ->
          expect(pattern).toBe("test-pattern")
          callback(null, ["file1","file2","file3"])
        spyOn(RandomWallpaper,"generateWallpaperStyle").andCallFake (path) ->
          expect(["file1","file2","file3"]).toContain(path)
          return path
        spyOn(atom.styles,"addStyleSheet")
        RandomWallpaper.changeWallpaper()
        expect(RandomWallpaper.glob).toHaveBeenCalled()
        expect(RandomWallpaper.generateWallpaperStyle).toHaveBeenCalled()
        expect(atom.styles.addStyleSheet).toHaveBeenCalled()
        RandomWallpaper.glob.andCallThrough()
        RandomWallpaper.generateWallpaperStyle.andCallThrough()

    describe "RandomWallpaper::insertWallpaper", ->
      it "was processed", ->
        spyOn(RandomWallpaper,"removeWallpaper")
        spyOn(RandomWallpaper,"changeWallpaper")
        spyOn(RandomWallpaper,"generateStyle")
        spyOn(atom.styles,"addStyleSheet")
        spyOn(workspaceElement.classList, 'add')
        RandomWallpaper.insertWallpaper()
        expect(RandomWallpaper.removeWallpaper).toHaveBeenCalled()
        expect(RandomWallpaper.changeWallpaper).toHaveBeenCalled()
        expect(RandomWallpaper.generateStyle).toHaveBeenCalled()
        expect(atom.styles.addStyleSheet).toHaveBeenCalled()
        expect(workspaceElement.classList.add).toHaveBeenCalledWith('random-wallpaper')

    describe "RandomWallpaper::removeWallpaper", ->
      it "was not processed", ->
        RandomWallpaper.inserted_styles.common = null
        RandomWallpaper.inserted_styles.wallpaper = null
        spyOn(workspaceElement.classList, 'remove')
        RandomWallpaper.removeWallpaper()
        expect(workspaceElement.classList.remove).toHaveBeenCalledWith('random-wallpaper')
      it "was processed", ->
        RandomWallpaper.inserted_styles =
          common:
            dispose: ->
              "test"
          wallpaper:
            dispose: ->
              "test"
        spyOn(RandomWallpaper.inserted_styles.common, 'dispose')
        spyOn(RandomWallpaper.inserted_styles.wallpaper, 'dispose')
        spyOn(workspaceElement.classList, 'remove')
        RandomWallpaper.removeWallpaper()
        expect(RandomWallpaper.inserted_styles.common).toBeNull()
        expect(RandomWallpaper.inserted_styles.wallpaper).toBeNull()
        expect(workspaceElement.classList.remove).toHaveBeenCalledWith('random-wallpaper')
      it "was processed (only wallpaper)", ->
        RandomWallpaper.inserted_styles =
          common: null
          wallpaper:
            dispose: ->
              "test"
        spyOn(RandomWallpaper.inserted_styles.wallpaper, 'dispose')
        spyOn(workspaceElement.classList, 'remove')
        RandomWallpaper.removeWallpaper()
        expect(RandomWallpaper.inserted_styles.common).toBeNull()
        expect(RandomWallpaper.inserted_styles.wallpaper).toBeNull()
        expect(workspaceElement.classList.remove).toHaveBeenCalledWith('random-wallpaper')

    describe "RandomWallpaper::activateAutoChange", ->
      it "was not processed", ->
        RandomWallpaper.settings.autoChangeIntervalSeconds = null
        spyOn(RandomWallpaper, 'deactivateAutoChange')
        spyOn(window, 'setInterval')
        RandomWallpaper.activateAutoChange()
        expect(RandomWallpaper.deactivateAutoChange).toHaveBeenCalled()
        expect(setInterval).not.toHaveBeenCalled()
      it "was processed", ->
        RandomWallpaper.settings.autoChangeIntervalSeconds = 12345
        spyOn(RandomWallpaper, 'deactivateAutoChange')
        spyOn(window, 'setInterval')
        RandomWallpaper.activateAutoChange()
        expect(RandomWallpaper.deactivateAutoChange).toHaveBeenCalled()
        expect(setInterval).toHaveBeenCalled()

    describe "RandomWallpaper::deactivateAutoChange", ->
      it "was not processed", ->
        RandomWallpaper.auto_change_interval_handle = null
        spyOn(window, 'clearInterval')
        RandomWallpaper.deactivateAutoChange()
        expect(clearInterval).not.toHaveBeenCalled()
        expect(RandomWallpaper.auto_change_interval_handle).toBeNull()
      it "was processed", ->
        RandomWallpaper.auto_change_interval_handle = 12345
        spyOn(window, 'clearInterval')
        RandomWallpaper.deactivateAutoChange()
        expect(clearInterval).toHaveBeenCalledWith(12345)
        expect(RandomWallpaper.auto_change_interval_handle).toBeNull()

    describe "RandomWallpaper::generateWallpaperStyle", ->
      it "is not empty", ->
        style = RandomWallpaper.generateWallpaperStyle()
        expect(style).not.toBe("")
        expect(style).toBeTruthy()
        expect(style.length).toBeGreaterThan(0)
      it "is contains 'background-image'", ->
        style = RandomWallpaper.generateWallpaperStyle()
        expect(style).not.toBe("")
        expect(style).toBeTruthy()
        expect(style.length).toBeGreaterThan(0)
        expect(style).toMatch(/background-image/)
      it "is contains 'args'", ->
        style = RandomWallpaper.generateWallpaperStyle("image-url")
        expect(style).not.toBe("")
        expect(style).toBeTruthy()
        expect(style.length).toBeGreaterThan(0)
        expect(style).toMatch(/url\("image-url"\)/)

    describe "RandomWallpaper::generateStyle", ->
      it "is not empty", ->
        style = RandomWallpaper.generateStyle()
        expect(style).not.toBe("")
        expect(style).toBeTruthy()
        expect(style.length).toBeGreaterThan(0)
