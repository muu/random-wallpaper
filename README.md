# ランダム壁紙 (Random Wallpaper)

Atomに壁紙を表示します。
- 複数の画像からランダムで表示する
- 一定時間毎に自動で切り替える
- 壁紙の明るさや透明度を調整することができる

Display wallpaper on Atom.
- Randomly display from multiple images
- Automatically switch at regular time intervals
- You can adjust the brightness and transparency of the wallpaper

## 壁紙の指定方法 (Usage)

ワイルドカード記号を使って複数の画像を指定できます。設定の書式はglob形式です。

You can specify multiple images using wild card symbols. The setting format is glob type.

書式例 (Example)
`c:/Users/yamada/Pictures/**/*.?(png|jpg)`

globの書式については下記を参考にしてください。

Please refer to the following for the format of glob.

https://www.npmjs.com/package/glob#glob-primer

## 注意事項 (Note)

テーマの背景を強制的に透明化し壁紙表示を行っています。そのため、Atomのバージョンやテーマによっては動作しなかったり、表示が崩れる可能性があります。

We forcibly make the background of the themes transparent and display wallpaper. Therefore, it may not work depending on the version of Atom and theme, or the display may collapse.

細部の調整が必要な場合はユーザスタイルシート(styles.less)で行ってください。

Please use user stylesheet (styles.less) if detail adjustment is necessary.

下記の環境およびテーマで調整を行いました。

We made adjustments in the following environment and theme.

- Atom 1.14.1 x64 (Windows)
- Themes
  - Atom Dark (UI & Syntax)
  - Atom Light (UI & Syntax)
  - One Dark (UI & Syntax)
  - One Light (UI & Syntax)
  - Base16 Tomorrow Dark (Syntax)
  - Base16 Tomorrow Light (Syntax)

## サンプル (Sample)

### Dark Theme
![Sample1 Dark](https://raw.githubusercontent.com/muu/random-wallpaper/master/screenshots/sample1-dark.jpg)
![Sample2 Dark](https://raw.githubusercontent.com/muu/random-wallpaper/master/screenshots/sample2-dark.jpg)

### Light Theme
![Sample1 Light](https://raw.githubusercontent.com/muu/random-wallpaper/master/screenshots/sample1-light.jpg)
![Sample2 Light](https://raw.githubusercontent.com/muu/random-wallpaper/master/screenshots/sample2-light.jpg)
