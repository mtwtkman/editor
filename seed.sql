PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
INSERT INTO "articles" VALUES(1,'github pagesに引越し','jekyllとか色々覚えることが多そうなのでpythonで必要最低限のhtmlのジェネレータを作ってgithub pagesにお引越ししてみました。

記事の情報はyamlで管理して、そいつをパースしてhtmlに吐き出すという感じにしてるのですが、自分しか使わないしかなり雑。

記事の情報管理をyamlでやるのはすごくいいということがわかってきました。

yamlは
```yaml
title: github pagesに引越し
slug: moved_to_gh_page
utime: 1455438723
date: 2016/02/14 17:32:03
tags:
  - タグ
active: true
body: |-
  ほにゃらら
```

という構成にしていて、こいつをpythonのPyYamlで読み込んだ結果をjinja2で書いたテンプレートにrenderしてやるようにしています。

面倒なのが、リポジトリのトップにあるindex.htmlへ記事の追加を反映しなくてはいけないので都度ビルドコマンドを叩くようにしています。

この辺はいちいちコマンドを叩かずに変更を監視して自動でビルドするようにしたいなぁと。

まあとにかくブログに特化するというのであればgithub pagesでもイケそうな気がする。',1,'2016-02-14 17:32:03','2016-02-14 17:32:03');
INSERT INTO "articles" VALUES(2,'github pagesの構成を変えた','引越しをした時は、pythonで記事データになるyamlファイルをビルドしてhtmlをした後にindex.htmlにリンクを載せるという方法を取っていました。

このやり方でも問題はないんですが、yamlとhtmlが重複してしまいなんともいけてない感じがしたので、yamlをjsで読み取る方法にしました。

どうせgithubがストレージなんだし記事の目録を作ってやってjsでyamlファイルをパースしてやればええがなという動機です。SPAの利です。

jsのフレームワークはなんとなく好きなmithrilを使って組んでいます。ブログみたいな単純なものならちょろっと書けるので最高。

でも結局は、目録を作るというのに変わっただけで記事を新規作成ないし削除をしたら目録を更新しないといけません。circleciとか使ってうまくできないか調べよう。

ところで、webpackのloaderは本当に最高で何も考えずにただただ`yaml-loader`を使えば全てが丸く収まるのでもうwebpackから抜け出せなくなりました。

ガンガン使っていきましょう。',1,'2016-02-21 18:38:37','2016-02-21 18:38:37');
INSERT INTO "articles" VALUES(3,'pythonの__new__とかtypeなど','pythonコードの読み書き練習のために便利ツールの[percol](https://github.com/mooz/percol)のリファクタリングを始めました。

`percol.finder`という文字列検索処理をしてるっぽいモジュールでメタクラスが使われていたのでメタクラスについてエキパイを読み直しました。

つっても、`percol.finder.Finder`クラスは[ただの抽象基底クラスというだけっぽい。](https://github.com/mooz/percol/blob/master/percol/finder.py#L11-L37)

メタプログラミングなんて高度なことをする場面は中々ないと思うけど、とりあえず`__new__`と`type()`について忘れたくないのでメモ。

```
$ python -V
Python 3.5.0
```

# \_\_new\_\_
`__new__`はインスタンスを作成しようとする時に毎回実行される。エキパイ的には`meta-constructor`と説明されている。

```python
class C(object):
  def __new__(cls, *args, **kwargs):
      print(''args: {}''.format(args))
      print(''kargs: {}''.format(kwargs))
      print(''__new__ called.'')
      ins = object.__new__(cls)
      print(''created instance'')
      ins.hoge = ''hoge''
      return ins

  def __init__(self, arg):
      print(''__init__ called.'')
      self._fuga = arg

  @property
  def fuga(self):
      return self._fuga + self.hoge


print(C(''fuga'').fuga)
# args: (''fuga'',)
# kargs: {}
# __new__ called.
# created instance
# __init__ called.
# fugahoge
```

`__new__`はクラスオブジェクトを引数にとって必ずインスタンスを返さなくてはいけない。つまり、インスタンスを作成する前にクラスオブジェクトを煮るなる焼くなり自由にいじり倒すことができるわけだ。

で、この`C`クラスを継承した場合、子クラスから親クラスの`__init__()`を呼び出すには`super()`をしないといけない。

```pytyhon
class C(object):
    def __new__(cls, *args, **kwargs):
        print(''C.__new__ called.'')
        return object.__new__(cls)

    def __init__(self):
        print(''C.__init__ called.'')


class D(C):
    def __init__(self):
        print(''D.__init__() called'')


class E(C):
    def __init__(self):
        super().__init__()
        print(''E.__init__() called'')


print(D())
# C.__new__ called.
# D.__init__() called
# <__main__.D object at 0x104616f28>

print(E())
# C.__new__ called.
# C.__init__ called.
# E.__init__() called
# <__main__.E object at 0x104616f98>
```

なるほど。

# metaclassとtype
`metaclass`はクラスのコンストラクタに渡すキーワード引数になる。python2では`__metaclass__`というクラス属性。

`metaclass`は`type()`と同じ形式の引数を取る関数が指定する。

```python
def mymetaclass(cls, base, _dict):
  if ''__cat__'' in _dict:
      _dict[''__cat__''] = \
          ''oh! my {}''.format(_dict.get(''__cat__'', ''''))
  return type(cls, base, _dict)


class A(object, metaclass=mymetaclass):
    __cat__ = ''neko''


print(a.__cat__)
# oh! my neko
```

全く実用的な例ではないけど、クラスの属性を自由に操作できる。というか、`type()`に渡す基底クラスを変えてしまえば自由にクラスオブジェクトを変更できてしまう。

エキパイにも

>For changing the read-write attributes or adding new ones, metaclasses can be avoided for simpler solutions, based on dynamic changes over the class instance.

というふうに書いてあるし、そう気軽に使っていいものではないことがわかる。(というか、使えないだろう。)

で、エキパイのこのチャプタの最後にクラスを拡張するパッチの実装があるのでほぼ丸コピ。

```python
def enhancer_1(cls):
  cls.contracted_name = ''''.join(
      l for l in cls.__name__ if l.isupper()
  )


def enhancer_2(cls):
    def logger(func):
        def wrapper(*args, **kwargs):
            print(''logging!'')
            return func(*args, **kwargs)
        return wrapper
    for el in dir(cls):
        if el.startswith(''_''):
            continue
        v = getattr(cls, el)
        if not hasattr(v, ''__func__''):
            continue
        setattr(cls, el, logger(v))


def enhance(cls, *enhancers):
    for e in enhancers:
        e(cls)


class ThisIsMyClass(object):
    def hi(self):
        return ''hi''


enhance(ThisIsMyClass, enhancer_1, enhancer_2)
ins = ThisIsMyClass()
assert ins.hi() == ''hi''
assert ins.__class__.contracted_name == ''TIMC''
```

なお、メタプログラミングを使うべき時が来、適切に使える時が来るのかガチ不明。',1,'2016-02-26 12:32:48', '2016-02-26 12:32:48');
INSERT INTO "articles" VALUES(4,'Gyazo APIのクライアントを雑に作った','Gyazo APIが非常にシンプルなため本当にシンプルな面白みのない実装になりました。

[pypi](https://pypi.python.org/pypi/pyazo)

[github](https://github.com/mtwtkman/pyazo)

pyazoって名前は別言語でかぶってたりしてアレ感ある。

ところでこういう外部のAPIのテストってどうしたらいいんじゃろ',1,'2016-03-13 09:19:21','2016-03-13 09:19:21');
INSERT INTO "articles" VALUES(5,'V8で最適化されないjavascript','[mithril](https://github.com/lhorie/mithril.js)のコードを読んでいて`for`文で`argumets`の要素をぐるぐる回しながらインデクスアクセスをして配列にデータを詰め込んでる処理が気持ち悪かったので`map`にしてプルリクしたところ、
パフォーマンスを理由にリジェクトされました。

で、そのプルリクでもらった返答にV8の最適化についてのリンクを併記してもらっていたので読むことにしました。

ちなみに[プルリクで修正した内容](https://github.com/lhorie/mithril.js/pull/993/commits/f384054947681d10696fcfeb2fab71f2a40dde1d)はクソ単純で
Arraylikeな`arguments`を`slice`で回すというものです。

[Optimization killersのリンク](https://github.com/petkaantonov/bluebird/wiki/Optimization-killers)

# Unsupported syntax
2016/3/19現在、V8で最適化できない構文がいくつかある。

- Generator functions
- Functions that contain a for-of statement
- Functions that contain a try-catch statement
- Functions that contain a try-finally statement
- Functions that contain a compound let assignment
- Functions that contain a compound const assignment
- Functions that contain object literals that contain __proto__, or get or set declarations.

`try`文ダメってキツそう。あと`for-of`が最適化されないのもつらい。まあ`for-of`が最適化されるならそっち使うよな。

generatorもダメとは…こう見ると単純にES2015以降に対応しきれていないだけという感じか。

あとは↓の場合もダメっぽい

- Functions that contain a debugger statement
- Functions that call literally eval()
- Functions that contain a with statement

VBAみたいで悔しい思いをしそうな`with`を使うことはない気がするけど、`eval`や`with`を最適化ができない理由はスコープの判定ができないからとのことらしい。(曖昧)

で、プロダクトコードで例外処理を避けるわけにもいかんということでワークアラウンドなコード例が書いてあったのでそのまま引用。

```javascript
var errorObject = {value: null};
function tryCatch(fn, ctx, args) {
    try {
        return fn.apply(ctx, args);
    }
    catch(e) {
        errorObject.value = e;
        return errorObject;
    }
}

var result = tryCatch(mightThrow, void 0, [1,2,3]);
//Unambiguously tells whether the call threw
if(result === errorObject) {
    var error = errorObject.value;
}
else {
    //result is the returned value
}
```

エラーハンドリングは独立した最小限の関数に切り出すのが良いらしい。
そうすれば最適化されない範囲が最小限になるということだ。


# Managing `arguments`
`arguments`は最適化を阻害する多数の原因になりうるやつだそうだ。

## 1. sloppyモード(=strictモードじゃないやつ)で`arguments`を評価しながら定義済みの引数に再代入する場合
何言ってんだ？？？？例を見てみよう

```javascript
function defaultArgsReassign(a, b) {
  if (arguments.length < 2) b = 5;
}
```

とにかくこれがダメということらしい。じゃあどうしたらいいのかというと引数の値を新しい変数に保存しましょうとのこと

```javascript
function reAssignParam(a, b_) {
  var b = b_;
  //unlike b_, b can safely be reassigned
  if (arguments.length < 2) b = 5;
}
```

ただし、今回の場合だとただ引数が与えられているのかをチェックしているだけなので下記のように書くのがいいっぽい。

```javascript
function reAssignParam(a, b) {
  if (b === void 0) b = 5;
}
```

まあでもおとなしく端からstrictモードにしておけば考える必要のない問題ですね。

## 2. `arguments`漏れ
```javascript
function leaksArguments1() {
  return arguments;
}

function leaksArguments2() {
  var args = [].slice.call(arguments);
}

function leaksArguments3() {
  var a = arguments;
  return function() {
      return a;
  };
}
```

今回のプルリクで指摘されたのが`leaksArguments2`と同じケースだった。`arguments`はどこにも漏らしたり渡したりしてはいけないらしい。

つまり`slice.call`や`map`の引数に渡すのはご法度いうわけだ。対処法は以下(mithrilの`m()`でまさに下の実装になっていた)

```javascript
function doesntLeakArguments() {
                  //.length is just an integer, this doesn''t leak
                  //the arguments object itself
  var args = new Array(arguments.length);
  for(var i = 0; i < args.length; ++i) {
              //i is always valid index in the arguments object
      args[i] = arguments[i];
  }
  return args;
}
```

## 3. `arguments`への代入
こんなことする必要性がないと思うけど、これも例によってsloppyモードの時だけ。

```javascript
function assignToArguments() {
  arguments = 3;
  return arguments;
}
```

## 結局のところ`arguments`はどうやったら安全に扱えるのか
以下を厳守すればok

- `arguments.length`使おう。
- 適切なインデクスアクセスで`arguments`の要素を取得する。で、そいつは外に出さない。
- `argumets`を**絶対に**直接扱わない。`.length`やインデクスアクセスは`arguments`そのものじゃないからおk。
- **厳密に言えば**`fn.apply(y, arguments)`はおk。他はいかなる場合もダメ。例えば`.slice`とか。 `Function#apply`だけが特別。
- `Function#apply`を使って関数のプロパティを追加するときと`Function#bind`で隠れクラスができてしまうような場合に気をつける。


# Switch-case
`switch`文は`case`の節が128を超えると最適化がされなくなる。なので`if-else`使おう。

# For-in
幾つかの場合で最適化を妨げることになる。

## 1. キーがローカル変数でない場合
```javascript
function nonLocalKey1() {
  var obj = {}
  for(var key in obj);
  return function() {
      return key;
  };
}

var key;
function nonLocalKey2() {
  var obj = {}
  for(key in obj);
}
```

そもそもオブジェクトのキーは上のスコープから参照できない。純粋にローカルスコープの変数でないとダメ。

## 2. イテレートできるようなオブジェクトは''simple enumerable''ではない
### `hash table mode`(あるいは`normalized objects`, `dictionary mode`)のオブジェクトは''simple enumerable''ではない。

```javascript
function hashTableIteration() {
  var hashTable = {"-": 3};
  for(var key in hashTable);
}
```

これわかりづらいのだけど、コンストラクタ外で動的に`hash table mode`のオブジェクトを作るのがよくないらしい。

オブジェクトが`hash table mode`になっているかはコード内に`console.log(%HasFastProperties(obj))`を仕込んでnodeのオプションに`--allow-natives-syntax`を指定してやればいいらしい。


### プロトタイプチェインで定義されたオブジェクトがenumerableなプロパティを持っている

```javascript
Object.prototype.fn = function() {};
```

プロトタイプチェインで追加した値は`for-in`文を含んでしまうらしい。

`Object.defineProperty`を使えばそれは避けられるらしい。慣れていないと難しい話だ。

### 配列のインデクスを持っている
これは結構やりがちかもしれない

```javascript
function iteratesOverArray() {
  var arr = [1, 2, 3];
  for (var index in arr) {

  }
}
```

そもそも`for-in`は`for`より遅いらしい。なおかつ`for-in`を含む関数は含んでいるというそれだけで関数全体の最適化がなされない。

これらの問題に対する処置としてキー名のリストを作ってしまえということだ。

```javascript
function inheritedKeys(obj) {
  var ret = [];
  for(var key in obj) {
      ret.push(key);
  }
  return ret;
}
```

まじかよ


# 無限ループと曖昧な脱出の条件
必ず一回はループを通るなら`do-while`使おう。あとはまあロジックを踏まえて適切にexit仕掛けようね。ということらしい。

現場からは以上です。',1,'2016-03-19 21:52:40','2016-03-19 21:52:40');
INSERT INTO "articles" VALUES(6,'shellのパイプをpythonで実装','なんかふとできるかなと思って試してみたところ以下のような感じになりました。

```python
class Pipable:
    def __init__(self, cmd):
        if callable(cmd):
            self.cmd = cmd
        else:
            raise ValueError

    def __ror__(self, other):
        return self.cmd(other)

    def __call__(self, *args):
        return self.cmd(*args)


def cat(f):
    with open(f) as fp:
        data = fp.read()
    return data


p1 = Pipable(cat)
p2 = Pipable(lambda x: x.upper())
p3 = Pipable(lambda x: ''-''.join(x))


assert p1(''hoge.txt'') == ''neko\n''
assert p1(''hoge.txt'') | p2 == ''NEKO\n''
assert p1(''hoge.txt'') | p2 | p3 == ''N-E-K-O-\n''
```

要は`p3(p2(p1(''hoge.txt'')))`という状態にしてやればいいので(関数合成というやつ？)`__ror__`で左側の処理の結果を受け取るようにしました。

実用性皆無マンです。',1,'2016-03-21 21:34:50','2016-03-21 21:34:50');
INSERT INTO "articles" VALUES(7,'鉄道指向プログラミングをpythonで','[Railway oriented programming](http://fsharpforfunandprofit.com/posts/recipe-part2/)を参考にpythonでも鉄道指向プログラミングを実装してみます。

F#全くわらかないけど、どうやら[判別共用体](https://msdn.microsoft.com/ja-jp/library/dd233226.aspx)というやつで処理結果の型を持ち回るということらしいので、そんな風に書いてみます。

```python
from functools import partial


class TSuccess:
    def __init__(self, result):
        self.result = result

    def __call__(self):
        return self.result


class TFailure:
    def __init__(self, msg):
        self.msg = msg

    def __call__(self):
        return lambda : self.msg


def bind(switch_func, two_track_input):
    if isinstance(two_track_input, TSuccess):
        return switch_func(two_track_input())
    elif isinstance(two_track_input, TFailure):
        return two_track_input


def validate1(inp):
    if inp.name == '''':
        return TFailure(''input name.'')
    else:
        return TSuccess(inp)


def validate2(inp):
    if len(inp.name) > 50:
        return TFailure(''name length must be less than 50.'')
    else:
        return TSuccess(inp)


def validate3(inp):
    if inp.email == '''':
        return TFailure(''input email.'')
    else:
        return TSuccess(inp)


class Input:
    def __init__(self, name, email):
        self._name = name
        self._email = email

    @property
    def name(self):
        return self._name

    @property
    def email(self):
        return self._email

    def __call__(self):
        return ''Success name={}, email={}''.format(self._name, self._email)


def combined_validation(inp):
    result1 = validate1(inp)
    result2 = bind(validate2, result1)
    result3 = bind(validate3, result2)
    return result3()()


assert combined_validation(Input(name='''', email='''')) == ''input name.''
assert combined_validation(Input(name=''neko'', email='''')) == ''input email.''
assert combined_validation(Input(name=''neko'', email=''meow'')) == ''Success name=neko, email=meow''
```

F#では`Result`という判別共用体に`Success`と`Failure`を持っていて、型によってディスパッチするみたいですが、pythonでこれを実現する方法がわからなかった。

というか、これっていわゆるパターンマッチだと思うのでまあそれができればいいかということで`bind`で全てを丸く収めた感があります。',1,'2016-04-14 22:59:22','2016-04-14 22:59:22');
INSERT INTO "articles" VALUES(8,'モジュールグローバルよりクラス変数の方がパフォーマンス的に有利','[falcon](http://falconframework.org/)のソース読んでたら[こんなの](https://github.com/falconry/falcon/blob/50fec0fd6dc6e0019099f11a001097e1baccc9ee/falcon/api.py#L128-L135)があった。

```python
...
# PERF(kgriffs): Reference via self since that is faster than
# module global...
_BODILESS_STATUS_CODES = set([
    status.HTTP_100,
    status.HTTP_101,
    status.HTTP_204,
    status.HTTP_304
])
...
```

モジュールグローバルのインポートよりもクラス変数のアクセスの方が速いということらしい。

パス探索やらのプロセスがなくなるんだから当たり前だと思うけどどの程度差があるのか気になったのでプロファイルとってみた。


`module.py`

```python
var = ''I am module global.''
```

`test.py`

```python
import cProfile


TRIAL = 100000


class A:
    var = ''I am class variable''


def test_module_global():
    for x in range(TRIAL):
        from mod import var


def test_class_variable():
    for x in range(TRIAL):
        a = A()
        a.var


if __name__ == ''__main__'':
    cProfile.run(''test_module_global()'')
    cProfile.run(''test_class_variable()'')

```

10万回参照するということがあり得るのかわからないけど、試行回数は10万回とする。

結果から言うと

モジュールグローバルのインポートは
> 200161 function calls (200160 primitive calls) in 0.185 seconds

クラス変数のアクセスはインスタンスを作るのを含めても
> 4 function calls in 0.016 seconds

だった。

まあ圧倒的にクラス変数の方が速い。

けどもこれ別モジュールからこのクラスをインポートして使うとかだと大してコスト変わらん気がする。

`falcon.API` は基本的にアプリケーションを実行するためのインスタンスを作るのが目的のオブジェクトなんだろうけどどうせインポートするしなぁ。謎',1,'2016-05-05 12:31:24','2016-05-05 12:31:24');
INSERT INTO "articles" VALUES(9,'ES6で書いたコードをkarma+webpackでテスト','`webpack.config.js`がそのまま使えるのでES6向けの設定が非常に楽でした。その割には`karma webpack es6`とかでググっても情報が全然なくて悲しい。

前準備として`npm i -D karam-webpack`をしておきます。

```
// karama.conf.js
var webpackConfig = require(''./webpack.config.js'');

module.exports = function(config) {
  config.set({
    basePath: '''',
    frameworks: [''jasmine''],
    files: [
      ''src/tests/**/*Spec.js''
    ],
    exclude: [],
    preprocessors: {
      ''src/**/*.js'': [''webpack''],
      ''src/tests/**/*Spec.js'': [''webpack'']
    },
    webpack: webpackConfig,
    reporters: [''progress''],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: [''PhantomJS''],
    singleRun: false,
    concurrency: Infinity
  })
}
```

こんな設定ファイルを用意して`karma test`を実行するだけでES6で書いたコードのテストが実行できます。
`webpack.config.js`のエントリポイントをそのまま使っているのでインポートのパス探索を考える必要がないのが良いと思います。

`browserify`の方が楽かと思ったけどこれはこれで問題ないかと。',1,'2016-07-29 23:50:20','2016-07-29 23:50:20');
INSERT INTO "articles" VALUES(10,'mithriljsのコードを読む','[mithriljs](https://github.com/lhorie/mithril.js/tree/0159cd667ad85cd82d92fcb31a33f75be6539f6d)のコード読む。

現時点で`v0.2.5`だけど、コアな部分はそう変わらんだろう。コアなというのは、つまり`m.mount`とか。

というわけで`mithril`がレンダリングする`m.mount`から読むことにしよう。(2000行程度なら単体のファイルは読むのが比較的楽ということが知られています)

[ここ](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1475)
```js
m.mount = m.module = function (root, component) {
  if (!root) {
    throw new Error("Please ensure the DOM element exists before " +
      "rendering a template into it.")
  }
  var index = roots.indexOf(root)
  if (index < 0) index = roots.length
  var isPrevented = false
  var event = {
    preventDefault: function () {
      isPrevented = true
      computePreRedrawHook = computePostRedrawHook = null
    }
  }
  forEach(unloaders, function (unloader) {
    unloader.handler.call(unloader.controller, event)
    unloader.controller.onunload = null
  })
  if (isPrevented) {
    forEach(unloaders, function (unloader) {
      unloader.controller.onunload = unloader.handler
    })
  } else {
    unloaders = []
  }
  if (controllers[index] && isFunction(controllers[index].onunload)) {
    controllers[index].onunload(event)
  }
  return checkPrevented(component, root, index, isPrevented)
}
```
`m.mount`がやってることはUnloadableControllerな場合に`unloader`のイベントハンドラを登録しているというだけ。
注意を払わないといけないのは`event`内で定義されている`preventDefault`関数の中で`isPrevented`を巻き上げてる点だろうか。

まあ、大したことはやっていないので`checkPrevented`を見てみる。

[ここやで](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1437)

```js
function checkPrevented(component, root, index, isPrevented) {
  if (!isPrevented) {
    m.redraw.strategy("all")
    m.startComputation()
    roots[index] = root
    var currentComponent
    if (component) {
      currentComponent = topComponent = component
    } else {
      currentComponent = topComponent = component = {controller: noop}
    }
    var controller = new (component.controller || noop)()
    // controllers may call m.mount recursively (via m.route redirects,
    // for example)
    // 訳: controllersはm.mountを再帰的に呼び出し得る。(例えば、m.routeのリダイレクトを通じてとか)
    // this conditional ensures only the last recursive m.mount call is
    // applied
    // 訳: この条件式はm.mountが呼び出す最後の再帰が適用されてるかを確かめてるだけ。
    if (currentComponent === topComponent) {
      controllers[index] = controller
      components[index] = component
    }
    endFirstComputation()
    if (component === null) {
      removeRootElement(root, index)
    }
    return controllers[index]
  } else {
    if (component == null) {
      removeRootElement(root, index)
    }
    if (previousRoute) {
      currentRoute = previousRoute
    }
  }
}
```
`isPrevented`でない場合、`m.redraw.strategy`は[`m.prop`](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1553)だから、`all`を初期値としてセット。
`startComputation`を呼び出しているのでここでredrawのカウンタが始まる。

Componentを作ってからControllerをインスタンス化してる。`currentComponent === topComponent`はよくわからん。`currentComponent = topComponent = ほにゃらら`って必ずどちらも通る分岐に書いてあるし、常にtrueになるんでは？

で、[`endFirstComputation`](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1578)は`endComputation`に読み替えていい。

ここでこのDOMの描画のカウンタが終了した。初回の描画はとにかくComponentをインスタンス化するだけのようだ。詳しい描画処理については別の部分を見ないとダメみたいだ。(`endComputation`の`m.redraw`呼び出しなんだけど)

あと、どうやら`m.mount(document.body)`が合法という事らしい。

[`removeRootElement`](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1512)はメソッド名通り、DOM要素からControllerやComponent、仮想DOMのCacheなどを削除している。

ところで、描画の処理が全然わからないので続く。',1,'2016-08-22 20:54:01','2016-08-22 20:54:01');
INSERT INTO "articles" VALUES(11,'mithriljsのコードを読む(2)','さて、前回は`m.mount`の内容を見たところ、描画についてはわからなかった。

`endComputation`内で呼んでいる`m.redraw`の正体を暴こう。

[ここ](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1522)
```javascript
m.redraw = function (force) {
  if (redrawing) return
  redrawing = true
  if (force) forcing = true
  try {
    // lastRedrawId is a positive number if a second redraw is requested
    // before the next animation frame
    // lastRedrawId is null if it''s the first redraw and not an event
    // handler
    // 超意訳: lastRedrawIdはフレームの更新が必要な時に正の数値を持つ。
    if (lastRedrawId && !force) {
      // when setTimeout: only reschedule redraw if time between now
      // and previous redraw is bigger than a frame, otherwise keep
      // currently scheduled timeout
      // when rAF: always reschedule redraw
      // 超意訳: フレームの更新時間が規定を超えていれば更新する
      if ($requestAnimationFrame === global.requestAnimationFrame ||
          new Date() - lastRedrawCallTime > FRAME_BUDGET) {
        if (lastRedrawId > 0) $cancelAnimationFrame(lastRedrawId)
        lastRedrawId = $requestAnimationFrame(redraw, FRAME_BUDGET)
      }
    } else {
      redraw()
      lastRedrawId = $requestAnimationFrame(function () {
        lastRedrawId = null
      }, FRAME_BUDGET)
    }
  } finally {
    redrawing = forcing = false
  }
}
```
ここではフレームの更新有無を判定している。再描画処理の本体は`redraw`という内部関数のようだ。

[ここ](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1554)
```javascript
function redraw() {
  if (computePreRedrawHook) {
    computePreRedrawHook()
    computePreRedrawHook = null
  }
  forEach(roots, function (root, i) {
    var component = components[i]
    if (controllers[i]) {
      var args = [controllers[i]]
      m.render(root,
        component.view ? component.view(controllers[i], args) : "")
    }
  })
  // after rendering within a routed context, we need to scroll back to
  // the top, and fetch the document title for history.pushState
  // 訳: routeされているコンテキスト(うまく訳せない)内での描画後、ドキュメントのトップにスクロールする必要がある。
  //     後history.pushStateするためのドキュメントのタイトルを取得する
  if (computePostRedrawHook) {
    computePostRedrawHook()
    computePostRedrawHook = null
  }
  lastRedrawId = null
  lastRedrawCallTime = new Date()
  m.redraw.strategy("diff")
}
```
溜め込まれた`roots`のviewを`m.render`に渡している。いよいよ核心に迫ってきた感出てきた。

`computePreRedrawHook`と`computePostRedrawHook`は訳に書いてある処理をやっているだけ。描画が終われば`m.redraw.strategy`がdiffに更新されて、差分だけの更新になるわけだ。

`m.render`を見てみよう。

[ここ](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L1316)
```javascript
m.render = function (root, cell, forceRecreation) {
  if (!root) {
    throw new Error("Ensure the DOM element being passed to " +
      "m.route/m.mount/m.render is not undefined.")
  }
  var configs = []
  var id = getCellCacheKey(root)
  var isDocumentRoot = root === $document
  var node

  if (isDocumentRoot || root === $document.documentElement) {
    node = documentNode
  } else {
    node = root
  }

  if (isDocumentRoot && cell.tag !== "html") {
    cell = {tag: "html", attrs: {}, children: cell}
  }

  if (cellCache[id] === undefined) clear(node.childNodes)
  if (forceRecreation === true) reset(root)

  cellCache[id] = build(
    node,
    null,
    undefined,
    undefined,
    cell,
    cellCache[id],
    false,
    0,
    null,
    undefined,
    configs)

  forEach(configs, function (config) { config() })
}
```

mithrilでは仮想DOMをcellと呼んでいるようで、`getCellCacheKey`はキャッシュされているrootの仮想DOMのidを取得している。

で、nodeはまさにDOMのノードの事(まさに本当の意味でのDOMオブジェクト)で、キャッシュされていないDOMの場合、`clear`を呼び出している。

```javascript
function clear(nodes, cached) {
  for (var i = nodes.length - 1; i > -1; i--) {
    if (nodes[i] && nodes[i].parentNode) {
      try {
        nodes[i].parentNode.removeChild(nodes[i])
      } catch (e) {
        /* eslint-disable max-len */
        // ignore if this fails due to order of events (see
        // http://stackoverflow.com/questions/21926083/failed-to-execute-removechild-on-node)
        /* eslint-enable max-len */
      }
      cached = [].concat(cached)
      if (cached[i]) unload(cached[i])
    }
  }
  // release memory if nodes is an array. This check should fail if nodes
  // is a NodeList (see loop above)
  if (nodes.length) {
    nodes.length = 0
  }
}
```

`clear`は一番後ろの子ノードを親から削除している。ループ処理の対象の長さを変えてしまう倫理観は別の問題として、要するにこれは子ノードを一掃するだけの関数だ。

`m.render`に戻ろう。

ようやくたどり着いた`build`がDOM作成の本体だ。

これがまたしんどそうなので次回',1,'2016-08-24 21:42:14','2016-08-24 21:42:14');
INSERT INTO "articles" VALUES(12,'mithriljsのコードを読む(3)','`build`の中身読むぞ〜〜〜〜

[ここ](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L916)

まず長いコメントが目を引くのでそれを片付ける。
```javascript
function build(
  parentElement,
  parentTag,
  parentCache,
  parentIndex,
  data,
  cached,
  shouldReattach,
  index,
  editable,
  namespace,
  configs
) {
  /*
   * `build` is a recursive function that manages creation/diffing/removal
   * of DOM elements based on comparison between `data` and `cached` the
   * diff algorithm can be summarized as this:
   *
   * 1 - compare `data` and `cached`
   * 2 - if they are different, copy `data` to `cached` and update the DOM
   *     based on what the difference is
   * 3 - recursively apply this algorithm for every array and for the
   *     children of every virtual element
```

アルゴリズムは以下の通り。

1. `data`と`cached`を比較する
2. 差分があれば`cached`に`data`をコピーして差分に基づいた更新をDOMに対して行う
3. 全ての`data`の配列と仮想要素の子に対して上記工程を全て再帰的に適用する

なかなかシンプルだ。そして、差分産出の要となる`data`と`cached`についての説明が続く。
```javascript
   * The `cached` data structure is essentially the same as the previous
   * redraw''s `data` data structure, with a few additions:
   * - `cached` always has a property called `nodes`, which is a list of
   *    DOM elements that correspond to the data represented by the
   *    respective virtual element
   * - in order to support attaching `nodes` as a property of `cached`,
   *    `cached` is *always* a non-primitive object, i.e. if the data was
   *    a string, then cached is a String instance. If data was `null` or
   *    `undefined`, cached is `new String("")`
   * - `cached also has a `configContext` property, which is the state
   *    storage object exposed by config(element, isInitialized, context)
   * - when `cached` is an Object, it represents a virtual element; when
   *    it''s an Array, it represents a list of elements; when it''s a
   *    String, Number or Boolean, it represents a text node
```

`cached`は前回再描画した`data`のデータ構造と本質的には同じデータ構造である。以下補足。
- `cached`は常に`nodes`と呼ばれるプロパティを持つ。`nodes`はそれぞれの仮想要素に対応するDOM要素のリストである。
- `cached`のプロパティとして`nodes`をくっつけられるように`cached`は*常に*プリミティブでないオブジェクトである。(例えば文字列データはcachedにおいてはString型となる。`null`や`undefined`であればcachedは`new String('''')`とする)
- `cached`は`configContext`プロパティも持っている。これは`config`によって作成された状態を保持するためのものである。
- `cached`がObject型である場合、仮想要素を表している。Array型だった場合は要素のリストであり、String, Number, Boolean型の場合はテキストノードとなる。

つまり、`cached`は純粋なjavascriptの型ではなくDOMオブジェクトとして子ノードを持ちうる状態であることらしい。

以降は残りの引数についてのコメント。
```javascript
   * `parentElement` is a DOM element used for W3C DOM API calls
   * `parentTag` is only used for handling a corner case for textarea
   * values
   * `parentCache` is used to remove nodes in some multi-node cases
   * `parentIndex` and `index` are used to figure out the offset of nodes.
   * They''re artifacts from before arrays started being flattened and are
   * likely refactorable
   * `data` and `cached` are, respectively, the new and old nodes being
   * diffed
   * `shouldReattach` is a flag indicating whether a parent node was
   * recreated (if so, and if this node is reused, then this node must
   * reattach itself to the new parent)
   * `editable` is a flag that indicates whether an ancestor is
   * contenteditable
   * `namespace` indicates the closest HTML namespace as it cascades down
   * from an ancestor
   * `configs` is a list of config functions to run after the topmost
   * `build` call finishes running
   *
   * there''s logic that relies on the assumption that null and undefined
   * data are equivalent to empty strings
   * - this prevents lifecycle surprises from procedural helpers that mix
   *   implicit and explicit return statements (e.g.
   *   function foo() {if (cond) return m("div")}
   * - it simplifies diffing code
   */
```
| 引数 | 説明 |
|------|------|
|parentElement|W3C DOM APIが呼んでいるDOM要素|
|parentTag|textareaの値の処理の場合にのみ使われる|
|parentCache|複数のノードが存在する場合にノードを削除するために使われる|
|parentIndex, index|ノードのオフセットを算出するために使用される|
|data|差分算出の新しい方|
|cached|差分算出の古い方|
|shouldReattach|親ノードを再作成するかしないかを判定するフラグ|
|editable|祖先の要素がcontenteditableかどうかを判定するフラグ|
|namespace|直近のHTML名前空間(祖先からカスケードダウンしてくる)|
|configs|buildの実行が終わった後に動くconfig関数のリスト|

で、この処理でやってることを上から見ていくと`data`がtoStringできるかどうかを判定し、cacheを作り、`data`のデータ型によって処理を分けている。

```javascript
  data = dataToString(data)
  if (data.subtree === "retain") return cached
  cached = makeCache(data, cached, index, parentIndex, parentCache)

  if (isArray(data)) {
    return buildArray(
      data,
      cached,
      parentElement,
      index,
      parentTag,
      shouldReattach,
      editable,
      namespace,
      configs)
  } else if (data != null && isObject(data)) {
    return buildObject(
      data,
      cached,
      editable,
      parentElement,
      index,
      shouldReattach,
      namespace,
      configs)
  } else if (!isFunction(data)) {
    return handleTextNode(
      cached,
      data,
      index,
      parentElement,
      shouldReattach,
      editable,
      parentTag)
  } else {
    return cached
  }
}
```

- Arrayだったら`buildArray`
- Objectだったら`buildObject`
- 上のデータ型でもFunctionでもなかったら`handleTextNode`
- それでも条件が異なればcachedを返却

とそれぞれ分岐している。

`buildArray`は何をしているんだろう。[ここ](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L584)

```javascript
function buildArray(
  data,
  cached,
  parentElement,
  index,
  parentTag,
  shouldReattach,
  editable,
  namespace,
  configs
) {
  data = flatten(data)
  var nodes = []
  var intact = cached.length === data.length
  var subArrayCount = 0
```

`key`を使うことで余計な要素の再作成を避けている。アルゴリズムはこうだ。

```javascript
  // keys algorithm: sort elements without recreating them if keys are
  // present
  //
  // 1) create a map of all existing keys, and mark all for deletion
  // 2) add new keys to map and mark them for addition
  // 3) if key exists in new list, change action from deletion to a move
  // 4) for each key, handle its corresponding action as marked in
  //    previous steps
```

1. 存在している全てのkeysのマップを作成し、削除処理のためにマークする。
2. マップに新しいkeysを追加し、それらを追加処理のためにマークする。
3. keyが新しいリストに存在しているなら、削除処理から移動へとアクションを変更する。
4. それぞれのkeyについて、ステップ3で決められたマークに対応するアクションを処理する。

わかるようでイマイチわからないので大人しくコードを読み進める。

```javascript
  var existing = {}
  var shouldMaintainIdentities = false

  forKeys(cached, function (attrs, i) {
    shouldMaintainIdentities = true
    existing[cached[i].attrs.key] = {action: DELETION, index: i}
  })
```

なるほど、`cached`をループして、アクションを`DELTION`に設定している。ステップ1だ。

```javascript
  buildArrayKeys(data)
```

今度は`buildArrayKeys`ですか(;´Д`)
```javascript
function buildArrayKeys(data) {
  var guid = 0
  forKeys(data, function () {
    forEach(data, function (attrs) {
      if ((attrs = attrs && attrs.attrs) && attrs.key == null) {
        attrs.key = "__mithril__" + guid++
      }
    })
    return 1
  })
}
```

`data`の属性をループして`key`が設定されていなければ識別子として設定している。ステップ2だ。

で、`cached`が存在してさえいれば`diffKeys`を呼んで終わり。

```javascript
  if (shouldMaintainIdentities) {
    cached = diffKeys(data, cached, existing, parentElement)
  }
  // end key algorithm
```

だるい

```javascript
function diffKeys(data, cached, existing, parentElement) {
  var keysDiffer = data.length !== cached.length

  if (!keysDiffer) {
    forKeys(data, function (attrs, i) {
      var cachedCell = cached[i]
      return keysDiffer = cachedCell &&
        cachedCell.attrs &&
        cachedCell.attrs.key !== attrs.key
    })
  }

  if (keysDiffer) {
    return handleKeysDiffer(data, existing, cached, parentElement)
  } else {
    return cached
  }
}
```

`data`と`cached`の要素数が同じであれば`cached`と`data`の`key`が違うかどうかを判定しcachedをそのまま返却。

そうでなければ`handleKeysDiffer`を呼び出して返却値をそのまま返却。しんどい

```javascript
function handleKeysDiffer(data, existing, cached, parentElement) {
  forKeys(data, function (key, i) {
    existing[key = key.key] = existing[key] ? {
      action: MOVE,
      index: i,
      from: existing[key].index,
      element: cached.nodes[existing[key].index] ||
        $document.createElement("div")
    } : {action: INSERTION, index: i}
  })
```

`data`の`key`がすでに存在している場合は`MOVE`のアクションが与えられている。`element`が`cached`の`nodes`が持つ要素か、新規作成のdiv要素になっている。

`data`の`key`がまだ存在していなければ`INSERTION`のアクションが与えられている。

で、actionsにexistingのプロパティの値を溜め込んで

```javascript
  var actions = []
  for (var prop in existing) {
    if (hasOwn.call(existing, prop)) {
      actions.push(existing[prop])
    }
  }
```

アクションごとに処理してる。

```javascript
  var changes = actions.sort(sortChanges)
  var newCached = new Array(cached.length)

  newCached.nodes = cached.nodes.slice()

  forEach(changes, function (change) {
    var index = change.index
    if (change.action === DELETION) {
      clear(cached[index].nodes, cached[index])
      newCached.splice(index, 1)
    }
    if (change.action === INSERTION) {
      var dummy = $document.createElement("div")
      dummy.key = data[index].attrs.key
      insertNode(parentElement, dummy, index)
      newCached.splice(index, 0, {
        attrs: {key: data[index].attrs.key},
        nodes: [dummy]
      })
      newCached.nodes[index] = dummy
    }

    if (change.action === MOVE) {
      var changeElement = change.element
      var maybeChanged = parentElement.childNodes[index]
      if (maybeChanged !== changeElement && changeElement !== null) {
        parentElement.insertBefore(changeElement,
          maybeChanged || null)
      }
      newCached[index] = cached[change.from]
      newCached.nodes[index] = changeElement
    }
  })
```

大して難しいことしてない。`newCached`で`cache`を更新し、アクションごとに削除、追加、移動をしている。

で、戻ってくる。

```javascript
  var cacheCount = 0
  // faster explicitly written
  for (var i = 0, len = data.length; i < len; i++) {
    // diff each item in the array
    var item = build(
      parentElement,
      parentTag,
      cached,
      index,
      data[i],
      cached[cacheCount],
      shouldReattach,
      index + subArrayCount || subArrayCount,
      editable,
      namespace,
      configs)

    if (item !== undefined) {
      intact = intact && item.nodes.intact
      subArrayCount += getSubArrayCount(item)
      cached[cacheCount++] = item
    }
  }

  if (!intact) diffArray(data, cached, nodes)
  return cached
}
```

`data`の要素に対して`build`を呼び出し再帰処理している。　

最後の`diffArray`は`data`と`cached`の長さが異なる場合に呼ばれ、内容としては`nodes`から`cached`の要素を削除して`data`の長さに合わせている。

`cached`に残っている不要な要素を削除する目的のようだ。

まだ全然終わらんが、疲れたので続く',1,'2016-08-25 20:14:04','2016-08-25 20:14:04');
INSERT INTO "articles" VALUES(13,'mithriljsのコードを読む(4)','前回は`buildArray`まで読んだ。`buildObject`から読もうではないか。

[ここ](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L831)

```javascript
function buildObject( // eslint-disable-line max-statements
  data,
  cached,
  editable,
  parentElement,
  index,
  shouldReattach,
  namespace,
  configs
) {
  var views = []
  var controllers = []

  data = markViews(data, cached, views, controllers)
```

`data`がオブジェクトの場合、つまりコンポーネントの場合は`markViews`で何かをしている。見てみる。

```javascript
function markViews(data, cached, views, controllers) {
  var cachedControllers = cached && cached.controllers

  while (data.view != null) {
    data = checkView(
      data,
      data.view.$original || data.view,
      cached,
      cachedControllers,
      controllers,
      views)
  }

  return data
```

キャッシュされているControllerがないかを判定して`checkView`から`data`を作っている。見てみる。

```javascript
function checkView(
  data,
  view,
  cached,
  cachedControllers,
  controllers,
  views
) {
  var controller = getController(
    cached.views,
    view,
    cachedControllers,
    data.controller)

  var key = data && data.attrs && data.attrs.key
```
バケツリレーで頭がフットーしそうだが、`getController`でControllerを取得しているのは明白だ。さらに、`data`の`key`を取得している。

この辺はキャッシュされている仮想DOMをアレコレするためだろう。`getController`を見てみる。

```javascript
function getController(views, view, cachedControllers, controller) {
  var controllerIndex

  if (m.redraw.strategy() === "diff" && views) {
    controllerIndex = views.indexOf(view)
  } else {
    controllerIndex = -1
  }

  if (controllerIndex > -1) {
    return cachedControllers[controllerIndex]
  } else if (isFunction(controller)) {
    return new controller()
  } else {
    return {}
  }
}
```

差分描画のフラグで且つコンポーネントが作成されていればキャッシュされているControllerを返し、そうでなければ引数の`controller`をインスタンス化するか空のオブジェクトを返す。

まあその名の通りControllerを返しているだけだ。

`checkView`に戻ると

```javascript
  if (pendingRequests === 0 ||
      forcing ||
      cachedControllers &&
        cachedControllers.indexOf(controller) > -1) {
    data = data.view(controller)
  } else {
    data = {tag: "placeholder"}
  }
```

このif文は再描画を行える状態かキャッシュされているControllerが存在している場合に仮想DOM(`data.view`のreturn)を`data`に再代入している。

```javascript

  if (data.subtree === "retain") return data
  data.attrs = data.attrs || {}
  data.attrs.key = key
  updateLists(views, controllers, view, controller)
  return data
}
```

`data.subtree === "retain"`であれば`data`の更新は行わない。ここは[ドキュメントにひっそりと書いてある。](http://mithril.js.org/mithril.html#persisting-dom-elements-across-route-changes)

概要を書くと、retainが設定されていると`router`による画面再描画時にそのDOMは再構築されずにそのまま引き継がれるというもの。
コンポーネントを使い回す時などに設定することになる。(この文脈でコンポーネントは`data`のこと)

で、コンポーネントをキャッシュしている`views`と`controllers`に作成した`view`と`controller`突っ込んでいる。

`buildObject`に戻ります。

```javascript
  if (data.subtree === "retain") return cached
```

上述した通り、retainの時はコンポーネントを使い回す。

```javascript

  if (!data.tag && controllers.length) {
    throw new Error("Component template must return a virtual " +
      "element, not an array, string, etc.")
  }

  data.attrs = data.attrs || {}
  cached.attrs = cached.attrs || {}

  var dataAttrKeys = Object.keys(data.attrs)
  var hasKeys = dataAttrKeys.length > ("key" in data.attrs ? 1 : 0)

  maybeRecreateObject(data, cached, dataAttrKeys)
```

ここからはconfigの設定かな。`maybeRecreateObject`を見てみる。

```javascript
function maybeRecreateObject(data, cached, dataAttrKeys) {
  // if an element is different enough from the one in cache, recreate it
  if (isDifferentEnough(data, cached, dataAttrKeys)) {
    if (cached.nodes.length) clear(cached.nodes)

    if (cached.configContext &&
        isFunction(cached.configContext.onunload)) {
      cached.configContext.onunload()
    }

    if (cached.controllers) {
      forEach(cached.controllers, function (controller) {
        if (controller.onunload) {
          controller.onunload({preventDefault: noop})
        }
      })
    }
  }
}
```

差分があった時に再作成するような要素だった場合に再作成している。で、`diffrent enough`であることを`isDifferentEnough`で見ている。

```javascript
function isDifferentEnough(data, cached, dataAttrKeys) {
  if (data.tag !== cached.tag) return true

  if (dataAttrKeys.sort().join() !==
      Object.keys(cached.attrs).sort().join()) {
    return true
  }

  if (data.attrs.id !== cached.attrs.id) {
    return true
  }

  if (data.attrs.key !== cached.attrs.key) {
    return true
  }

  if (m.redraw.strategy() === "all") {
    return !cached.configContext || cached.configContext.retain !== true
  }

  if (m.redraw.strategy() === "diff") {
    return cached.configContext && cached.configContext.retain === false
  }

  return false
}
```

trueになるのは
- attributesのキーがキャッシュされているのと異なる時
- attrsのidがキャッシュされているのと異なる時
- `key`がキャッシュされているのと異なる時
- strategyが`all`でかつ、`config`がないまたはretainが設定されていない時
- strategyが`diff`でかつ、`config`があってretainが設定されていない時

ちなみに、strategyは↓の通り
| all | デフォルトの値。redrawのタイミングで現在のDOMを捨てて全部作り直す|
| diff | 差分があったときだけその差分更新を行う |
| none | redrawをすっ飛ばす。何も更新はしない |

`all`でかつ`config`がない時というのがピンとこないが、おそらく`config`は`redraw`のタイミングで常に呼ばれるからキャッシュ前提のためだろう。

```javascript

  if (!isString(data.tag)) return
```

ここはどういうことだかよくわからない。`tag`が文字型でなければエラーではなく無を返す…どういうことだ…

[m()ではエラーにしてるぞ?](https://github.com/lhorie/mithril.js/blob/0159cd667ad85cd82d92fcb31a33f75be6539f6d/mithril.js#L168-L171)

よくわからないのでgitterで聞いてる中。

```javascript
  var isNew = cached.nodes.length === 0

  namespace = getObjectNamespace(data, namespace)
  var node
  if (isNew) {
    node = constructNode(data, namespace)
```
ここでDOM作ってる。

```javascript
    // set attributes first, then create children
    var attrs = constructAttrs(data, node, namespace, hasKeys)
```

DOMにアトリビュートをセット

```javascript
    // add the node to its parent before attaching children to it
    insertNode(parentElement, node, index)
```

子ノードとして親要素に追加

```javascript
    var children = constructChildren(data, node, cached, editable,
      namespace, configs)
```

子ノードを作成。この中でさらに`build`を呼んで子ノードのDOMを作成している。

```javascript
    cached = reconstructCached(
      data,
      attrs,
      children,
      node,
      namespace,
      views,
      controllers)
  } else {
    node = buildUpdatedNode(
      cached,
      data,
      editable,
      hasKeys,
      namespace,
      views,
      configs,
      controllers)
  }

```

初回の`build`であればキャッシュを作り、そうでなければ`data`の情報で`cached`を更新する。

```javascript
  // edge case: setting value on <select> doesn''t work before children
  // exist, so set it again after children have been created/updated
  if (data.tag === "select" && "value" in data.attrs) {
    setAttributes(node, data.tag, {value: data.attrs.value}, {},
      namespace)
  }
  if (!isNew && shouldReattach === true && node != null) {
    insertNode(parentElement, node, index)
  }

  // The configs are called after `build` finishes running
  scheduleConfigsToBeCalled(configs, data, node, isNew, cached)

  return cached
}
```
どうやらselectタグが指定されていた場合は子要素がないとうまく動かないとのことでもう一度属性の設定をしている。

で、必要に応じて`node`を`index`の位置に追加して最後に`data`の`config`を`configs`に突っ込んで終了。


とりあえずこれでおしまいなんだが、まだあるんや…',1,'2016-08-27 20:18:23','2016-08-27 20:18:23');
INSERT INTO "articles" VALUES(14,'pythonでカリー化','やり尽くされてるだろうけどpythonでカリー化を実装してみました

```
import functools


class ArgumentCountError(Exception):
    pass


def curry(function):
    name = function.__name__
    argcount = function.__code__.co_argcount
    varnames = function.__code__.co_varnames
    class Factory:
        def __init__(self, function, params=None):
            self.function = function
            self._params = params if params else tuple()

        @property
        def name(self):
            return name

        @property
        def argcount(self):
            return argcount

        @property
        def varnames(self):
            return varnames

        def __call__(self, *args):
            params = self._params + args
            if self.argcount < len(params):
                raise ArgumentCountError
            elif self.argcount == len(params):
                return self.function(*args)
            else:
                return self.__class__(functools.partial(self.function, *args), params)

        def __str__(self):
            params = '', ''.join(
                ''{}={}''.format(*x) for x in zip(self.varnames, self._params)
            ) if self._params else ''NO PARAM SUPPLIED''
            return ''<{}: {}>''.format(self.name, params)
    return Factory(function)


if __name__ == ''__main__'':
    @curry
    def add(x, y, z):
        return x + y + z

    assert add(1, 2, 3) == add(1, 2)(3) == add(1)(2)(3) == 6
```

特に工夫はしてないです',1,'2016-09-21 22:50:27','2016-09-21 22:50:27');
INSERT INTO "articles" VALUES(15,'mithirl.jsのospec使ってみる','rewriteいいですね。mithrilのコードリーディングは完全に挫折したけどもうrewriteブランチを追うことにするのでいいやという感じ。

rewriteブランチには[ospec](https://www.npmjs.com/package/ospec)というフルスクラッチのテストフレームワークがあってやばくなっているので見てみます。

機能としては
- テストのグループ化
- アサーション
- スパイ
- `equals`, `notEquals`, `deepEquals`, `notDeepEquals`のアサーションタイプ
- `before`/`after`/`beforeEach`/`afterEach`の各フック
- 排他テスト(`.only`とか)
- 非同期なテストとフック
ということで一通り必要なものは揃っている印象です。

[APIも小柄です。](https://github.com/lhorie/mithril.js/tree/rewrite/ospec#api)

# インストール
`npm i ospec`

# 使い方
詳しくは[ドキュメント](https://github.com/lhorie/mithril.js/blob/rewrite/ospec/README.md)を見てください。

## 基本的な使い方
基本的な使い方は`o.spec`でテストのグループ化をして`o`でテストを作成。`o.run`でテストを実行という流れです。
```javascript
function kebabify(v) {
  if (typeof v !== ''string'') return null;
  return v.split('''').join(''-'');
}

var o = require(''ospec'');

o.spec(''kebabify'', function() {
  o(''return kebabed string if passed string'', function() {
    o(kebabify(''hoge'')).equals(''h-o-g-e'');
  })
  o(''return null if passed not string'', function() {
    o(kebabify(123)).equals(null);
  })
});

o.run();
```

テストが通るとアサーションの数だけが表示されます。
> 2 assertions completed in 23ms

テストが失敗するとどこで失敗したかが最低限表示されます。
>kebabify > shoud return null if passed not string: null should equal "1-2-3"
>
> at /Users/boku/work/jswork/hoge/tests/one.js:13:22
>
>
> 2 assertions completed in 23ms

素っ気ないですね。

`o.spec`はネストできます。

```javascript
function _anyfy(v, sign) {
  if (typeof v !== ''string'') return null;
  return v.split('''').join(sign);
}

function kebabify(v) { return _anyfy(v, ''-'') }
function snakify(v) { return _anyfy(v, ''_'') }

var o = require(''ospec'');

o.spec(''string case'', function() {
  o.spec(''kebabify'', function() {
    o(''shoud return kebabed string if passed string'', function() {
      o(kebabify(''hoge'')).equals(''h-o-g-e'');
    })
    o(''shoud return null if passed not string'', function() {
      o(kebabify(123)).equals(null);
    })
  });
  o.spec(''snakify'', function() {
    o(''shoud return snaked string if passed string'', function() {
      o(snakify(''hoge'')).equals(''h_o_g_e'');
    })
    o(''shoud return null if passed not string'', function() {
      o(snakify(123)).equals(null);
    })
  });
});

o.run();
```

また、`bin`に`ospec`があるのでコマンドで呼び出すこともできます。コマンドで呼び出す場合は`tests/*.js`がテスト定義ファイルとみなされます。

## スタブ
`o.spy`はスタブとして利用できます。例えばコールバック関数を引数に取る関数をテストする時に利用できるわけです。

```javascript
function one(cb, x, y) {
  console.log(''yeah, wow, wow, yeah'');
  cb(x, y);
  console.log(''oh...'');
  cb(x, y);
  console.log(''hey...'');
}

var o = require(''ospec'');

o.spec(''one()'', function() {
  o(''shoud work for me.'', function() {
    var spy = o.spy();
    one(spy, 10, 100);
    o(spy.callCount).equals(2);
    o(spy.args).deepEquals([10, 100]);
  });
});

o.run();
```

`o.spy`が返却するオブジェクトは`callCount`と`args`という属性を持っています。それぞれ呼ばれた回数とスタブ関数に**最後に渡された**引数の配列です。

## 非同期テスト
テストのスコープを作っている関数に引数を渡すとそれは非同期なものとみなされます。その引数はテスト完了時に必ず一度呼び出される関数です。

慣例的には`done`とかつけるみたいです。

```javascript
function asyncFunc(cb, wait) {
  wait = wait || 20;
  setTimeout(cb(), wait);
}

var o = require(''ospec'');

o(''setTimeout calls callback'', function(done, timeout) {
  timeout(50);
  asyncFunc(done, 10);
});

o.run();
```

あまりいい例じゃないけど(;´Д`)

ちなみにデフォルトで非同期テストのタイムアウトは`20ms`とのことでこれはテストのスコープを作ってる関数の第二引数に渡す関数によって設定を変えられる。

この引数は慣例的に`timeout`と名付けるのがいいようだ。

`done`が実行されれば成功してタイムアウトすると失敗とのことだけど、何度やっても成功してしまう。謎い。

## フック
テストの実行タイミングのフックがあります。
`before`と`after`はテストグループの実行前後に一度だけ実行されるフックです。
```javascript
function id(x) { return x; }

var o = require(''ospec'');

o.spec(''double'', function() {
  var acc;
  o.before(function() {
    acc = 0;
  });
  o(''should return himself.'', function() {
    acc++;
    o(id(acc)).equals(1);
  });
  o(''should return himself again.'', function() {
    acc++
    o(id(acc)).equals(2);
  });
});

o.run();
```

ちなみにテストの実行される順番は定義順ぽいですね。

`beforeEach`と`afterEach`はテストごとの実行前後のフックです。
```javascript
function id(x) { return x; }

var o = require(''ospec'');

o.spec(''double'', function() {
  var acc;
  o.beforeEach(function() {
    acc = 0;
  });
  o(''should return himself.'', function() {
    acc++;
    o(id(acc)).equals(1);
  });
  o(''should return himself again.'', function() {
    acc--;
    o(id(acc)).equals(-1);
  });
});

o.run();
```

フックの関数に`done`を渡すと非同期なフックとなります。`done`が実行された前後にテストがはしります。
```javascript
function id(x) { return x; }

var o = require(''ospec'');

o.spec(''double'', function() {
  var acc;
  o.beforeEach(function(done) {
    acc = 0;
    done();
  });

  // 非同期フックが完了したらテストが実行される。
  o(''should return himself.'', function() {
    acc++;
    o(id(acc)).equals(1);
  });
  o(''should return himself again.'', function() {
    acc--;
    o(id(acc)).equals(-1);
  });
});

o.run();
```

でもこれテストの結果に`beforeEach`内の非同期処理のアサーションも計上されているので微妙です。

## 排他的テスト
`o.only`によってそのテストだけを実行できます。
```javascript
var o = require(''ospec'');

o.spec(''test'', function() {
  o(''does not run.'', function() {
    o(1 + 1).equals(2);
  });

  o.only(''runs'', function() {
    o(1 * 10).equals(10);
  });
});

o.run();
```

> 1 ssertions completed in 22ms

## テストの並列実行
`o.new`することで新たな`o`のオブジェクトが生成できるので
```javascript
var o = require(''o'');
var _o = o.new();
...
o.run();
_o.runt();
```

として並列にテストが実行できます。


まだまだ荒削りな部分がありますが、多機能になりすぎて肥大化するよりかはマシだと感じます。js界隈のテストフレームワークは覚えるのと環境を整えるが億劫というのがあるのでこのくらいシンプルでいいのではという気づきがありますね。',1,'2016-10-23 22:04:55','2016-10-23 22:04:55');
INSERT INTO "articles" VALUES(16,'Rust の所有権を理解する','[Rustの公式ドキュメント](https://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/ownership.html)をじっくり咀嚼して、Rustコードを読み書きするしかないけどまずは概念をある程度理解していないと難しいので、できるだけ仲良くなろう。

そのためにも静的型付けのコンパイル言語という未経験なパラダイムということもあるので語学のためにも一言一句レベルで馬鹿丁寧にドキュメントを読み砕く。

特に、所有権、借用、参照は必ず理解しておきたいのでここでみておく。

# 所有権
> Rustでは 変数束縛 はある特性を持ちます。それは、束縛されているものの「所有権を持つ」ということです。 これは束縛がスコープから外れるとき、Rustは束縛されているリソースを解放するだろうということを意味します。

とある。これはつまりこういうことだ。

```rust
{
  let hoge = "var";  // 束縛
  println!("{}", hoge);
}
// スコープから外れたのでリソースを解放している。
// そのため、hoge を参照しようとするとエラーが発生。
println!("{}", hoge);
// error[E0425]: unresolved name `hoge`
//  --> src/main.rs:6:20
//    |
//  6 |     println!("{}", hoge);
//    |                    ^^^^ unresolved name
// error: aborting due to previous error
```

言い換えると、`letを用いた変数束縛は、束縛されたスコープ内でのみ生存可能なリソースの所有権を持つ`という特性を持つと言えそうだ。

# ムーブセマンティクス

> しかし、ここではもっと微妙なことがあります。それは、Rustは与えられたリソースに対する束縛が 1つだけ あるということを保証するということです。

ここではリソースに対する束縛、つまり所有権が1つだけであることを保証するRustについて微妙だと言っている。そして以下のような例が挙げられている。

```rust
let v = vec![1, 2, 3];
let v2 = v;
println!("{}", v[0]);
// error[E0382]: use of moved value: `v`
//  --> src/main.rs:4:20
//    |
//  3 |     let v2 = v;
//    |         -- value moved here
//  4 |     println!("{}", v[0]);
//    |                    ^ value used here after move
//    |
//    = note: move occurs because `v` has type `std::vec::Vec<i32>`, which does not implement the `Copy` trait
// error: aborting due to previous error
```
ここで発生したエラーの内容はムーブされた変数`v`を使うなということである。

> 所有権を何か別のものに転送するとき、参照するものを「ムーブした」と言います。

これは別に微妙でもなんでもなくて、リソースを所有できるのは常に唯一なんらかのオブジェクトであることがわかる。だから`v`が所有していたリソースの`v2`への転送(ムーブ)と表現しているわけだ。

この動作の詳細についての解説がされている。

> ベクタオブジェクトは スタック に保存され、 ヒープ に保存された内容（ [1, 2, 3] ）へのポインタを含みます。v を v2 にムーブするとき、それは v2 のためにそのポインタのコピーを作ります。 それは、ヒープ上のベクタの内容へのポインタが2つあることを意味します。

とのことで、確かにこれで`v`と`v2`からデータ競合が起きる可能性があるためRustがそれを排除するのは自然だ。それよりも重要なのはムーブにはポインタのコピーを伴うということだ。これは`v`が所有するリソースが保存されているアドレスと異なるアドレスに`v2`のオブジェクトが格納され、それに伴ってポインタのコピーが発生するということだろう。

だとしたらムーブというのは厳密には転送ではなくてコピーということなのではないだろうか。これはコンパイラの実装を見て理解できるのかどうかも怪しいがなんとも言えない。

# Copy型
`Copy`とは
> 所有権が他の束縛に転送されるとき、元の束縛を使うことができないということを証明しました。 しかし、この挙動を変更する トレイト があります。

と言っているトレイトである。上のコード例でも`Copy`トレイトが実装されていない`Vec<i32>`型の`v`のムーブだったため`v2`にムーブした後に`v`を使うことができずにエラーが出ていた。つまり`Copy`が実装されている型であれば万事解決というわけだ。

```rust
let v = 1;
let v2 = v;
println!("{}", v);
```

これは実際成功する。なぜなら`i32`は`Copy`を実装しているからだ。でもムーブが発生しているし、データの競合は起きるのでは？という疑問がある。それについては

> これはちょうどムーブと同じように、 v を v2 に割り当てるとき、データのコピーが作られるということを意味します。 しかし、ムーブと違って後でまだ v を使うことができます。 これは i32 がどこか別の場所へのポインタを持たず、コピーが完全コピーだからです。

ということらしい。`Copy`の実装がされていればムーブは実質的に完全コピー、見かけは同じでもメモリ上は全く別物のリソースとなるため所有権は完全に独立している。そのためRustのルールから逸脱していないわけだ。

> 全てのプリミティブ型は Copy トレイトを実装しているので、推測どおりそれらの所有権は「所有権ルール」に従ってはムーブしません。

とある。`「所有権ルール」に従っては`という表現は何か行間がありそうだが、単純にコピーをしていると読み替えても問題はなさそうだ。なぜなら上で推察した通り、それは1つのリソースが複数所有されているわけではないからだ。

# 所有権を越えて
関数への実引数として束縛した変数を渡すとムーブが起きる。そのため、関数の呼び出し元は関数がその所有権を返すようにしてもらわねばならない。

```rust
fn foo(v1: Vec<i32>, v2: Vec<i32>) -> (Vec<i32>, Vec<i32>, i32) {
  // `Copy`を実装しない`Vec`であるため`v`についてはムーブが起きる　
  // そのため、持ち主に対して所有権を返す必要がある
  (v1, v2, 42)
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let (v1, v2, n) = foo(v1, v2);
```

これはなんとも手間だ。しかしこれはRustがもともと提供する借用という機能を使うことで簡単に解決できる。

# 借用
借用を用いたコードはこのようになる

```rust
fn foo(v1: &Vec<i32>, v2: &Vec<i32>) -> Vec<i32> {
  42
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let n = foo(&v1, &v2);
// コンパイルが通る
println!("{}, {}", v1[0], v2[0]);
```

> 引数として Vec<i32> を使う代わりに、参照、つまり &Vec<i32> を使います。 そして、 v1 と v2 を直接渡す代わりに、 &v1 と &v2 を渡します。

`&Vec<i32`を「参照」であるといい、`&v1`とすることで`v1`を直接渡さなくて済むという。つまり参照を渡すと所有権の転送であるムーブは起きないということだろう。実際にこう解説されている。

> &T 型は「参照」と呼ばれ、それは、リソースを所有するのではなく、所有権を借用します。

参照をムーブが起きうる箇所で渡すことを所有権の借用という。

> 何かを借用した束縛はそれがスコープから外れるときにリソースを割当解除しません。 これは foo() の呼出しの後に元の束縛を再び使うことができることを意味します。

所有権の項で見た通り、束縛は本来「所有権を持つ」ことを言うが、その所有権が借用だった場合はリソースが解放されずに済む。当然のことだがとても大切だ。

> 参照は束縛とちょうど同じようにイミュータブルです。 これは foo() の中ではベクタは全く変更できないことを意味します。

これは安全にリソースを扱うRustの心意気という感じだが、普通に`&T`はイミュータブルなものとして扱われる。

ここまでの事実を整理すると借用とは

- `&T`の形式で表すリソースの参照を使う
- 所有権のムーブを回避し、束縛のスコープが終わってもリソースの解放をしない
- 特に指定がない限りはイミュータブル

ということが明らかになった。

# &mut参照
ミュータブルな束縛があるように、参照にもミュータブルなものがある。
> 参照には2つ目の種類、 &mut T があります。 「ミュータブルな参照」によって借用しているリソースを変更することができるようになります。

```rust
let mut x = 5;
{
  let y = &mut x;
  *y += 1;
}
println!("{}", x);
```

> y を x へのミュータブルな参照にして、それから y の指示先に1を足します。 x も mut とマークしなければならないことに気付くでしょう。 そうしないと、イミュータブルな値へのミュータブルな借用ということになってしまい、使うことができなくなってしまいます。

これは今まで得た知識で理解できることだ。ミュータブルな参照を借用した束縛は当然値を変更できる。

>   アスタリスク（ * ）を y の前に追加して、それを *y にしたことにも気付くでしょう。これは、 y が &mut 参照だからです。

アスタリスクを追加する理由として`y`が&mut参照であることが述べられている。値を変更するということはその実体にアクセスして書き換えねばならない。参照の内容にアクセするにはアスタリスクを使用する必要があるということだ。

> それ以外は、 &mut 参照は普通の参照と全く同じです。 しかし、2つの間には、そしてそれらがどのように相互作用するかには大きな違いが あります 。前の例で何かが怪しいと思ったかもしれません。なぜなら、 { と } を使って追加のスコープを必要とするからです。 もしそれらを削除すれば、次のようなエラーが出ます。

この理由として借用についてのルールが挙げられている。

- 借用は全て所有者のスコープより長く存続してはいけない
- 借用は`リソースに対する1つ以上の参照(&T)`または`ただ1つのミュータブルな参照(&mut T)`のどちらかを持つことがありうるが、両方同時に持つことはない

1つ目の借用がスコープが終わってもなお存在してしまった場合、本来の所有者と借用しているものが同スコープに並存してしまうことになる。これはRust的にはおかしいことだ。

2つ目はこれもリソースに対して所有権が1つしかあり得ないこととほぼ同じ制約だろう。

いずれにせよ、Rustはデータ競合を排除している。

# スコープの考え方
ドキュメントでは借用のルールを踏まえてスコープの考え方に立ち返っている。

このコードはエラーを出す。
```rust
let mut x = 5;
// x をミュータブルな借用をしている。
let y = &mut x;

// x と同じスコープで借用しているリソースを更新
*y += 1;

// 2つ目のルールに違反。また、このエラーは所有者のイミュータブルな参照をしようとしているため発生している。
println!("{}", x);
// error: cannot borrow `x` as immutable because it is also borrowed as mutable
//     println!("{}", x);
//                    ^
```

> 必要なものは、 println! を呼び出し、イミュータブルな借用を作ろうとする 前に 終わるミュータブルな借用です。 Rustでは借用はその有効なスコープと結び付けられます。 そしてスコープはこのように見えます。

```rust
let mut x = 5;

let y = &mut x;    // -+ xの&mut借用がここから始まる
                   //  |
*y += 1;           //  |
                   //  |
println!("{}", x); // -+ - ここでxを借用しようとする
                   // -+ xの&mut借用がここで終わる
```

`pintln!`で`x`を渡すのはムーブが起きるのではないのかという疑問は起きつつもこれはどうやら借用であるらしい。それによって起きるルール違反でコンパイルエラーが出るというわけだ。

ここからわかることは借用をする場合は所有者とのスコープの衝突を避けることを知っておかなければならない。

# 借用が回避する問題
> なぜこのような厳格なルールがあるのでしょうか。 そう、前述したように、それらのルールはデータ競合を回避します。

借用の存在意義はデータ競合の回避だと言っている。例えば

## イテレータの無効
> 一例は「イテレータの無効」です。それは繰返しを行っているコレクションを変更しようとするときに起こります。 Rustの借用チェッカはこれの発生を回避します。

```rust
let mut v = vec![1, 2, 3];

for i in &v {
    println!("{}", i);
}
```

`Vec<i32>`のミュータブルな束縛である`v`をイミュータブルな借用でイテレートしている。この借用は`for`のスコープのみ有効である。

```rust
let mut v = vec![1, 2, 3];

for i in &v {
    println!("{}", i);
        v.push(34);
}
//  error: cannot borrow `v` as mutable because it is also borrowed as immutable
//     v.push(34);
//     ^
// note: previous borrow of `v` occurs here; the immutable borrow prevents
// subsequent moves or mutable borrows of `v` until the borrow ends
// for i in &v {
//           ^
// note: previous borrow ends here
// for i in &v {
//     println!(“{}”, i);
//     v.push(34);
// }
// ^
```

ミュータブルな束縛であっても借用の仕方によって不意な変更を避けることができることがわかった。　

## 解放後の使用
> 参照はそれらの指示するリソースよりも長く生存することはできません。 Rustはこれが真であることを保証するために、参照のスコープをチェックするでしょう。

これも前述のルール通りだ。

```rust
let y: &i32;
{
    let x = 5;
    y = &x;
}

println!("{}", y);
// error: `x` does not live long enough
//     y = &x;
//          ^
// note: reference must be valid for the block suffix following statement 0 at
// 2:16...
// let y: &i32;
// {
//     let x = 5;
//     y = &x;
// }
//
// note: ...but borrowed value is only valid for the block suffix following
// statement 0 at 4:18
//     let x = 5;
//     y = &x;
// }
```

これは少し分かりづらい。まず、外側のスコープで`i32`の参照を束縛するために`y`を宣言した。内側のスコープでは`i32`である5を`x`に束縛し、その参照を`y`に束縛しようとした。コンパイラはそこでエラーを出している。
なぜなら、内側のスコープを抜けた瞬間に`x`のリソースは解放されてメモリ上から存在をなくしているため、存在しない`x`の参照を持つ`y`が外側のスコープで生きているからである。

> 言い換えると、 y は x が存在するスコープの中でだけ有効だということです。 x がなくなるとすぐに、それを指示することは不正になります。 そのように、エラーは借用が「十分長く生存していない」ことを示します。なぜなら、それが正しい期間有効ではないからです。

これはすごく安全という印象を受ける。

また

> 参照がそれの参照する変数より 前に 宣言されたとき、同じ問題が起こります。 これは同じスコープにあるリソースはそれらの宣言された順番と逆に解放されるからです。

```rust
let y: &i32;
let x = 5;
y = &x;

println!("{}", y);
// error: `x` does not live long enough
// y = &x;
//      ^
// note: reference must be valid for the block suffix following statement 0 at
// 2:16...
//     let y: &i32;
//     let x = 5;
//     y = &x;
//
//     println!("{}", y);
// }
//
// note: ...but borrowed value is only valid for the block suffix following
// statement 1 at 3:14
//     let x = 5;
//     y = &x;
//
//     println!("{}", y);
// }
```

参照(`&x`)がそれの参照する変数(`y`)と読み替えられる。つまり`x`より先に宣言した`y`は`x`より寿命が長いためにエラーが出ているということだ。

> 前の例では、 y は x より前に宣言されています。それは、 y が x より長く生存することを意味し、それは許されません。

そう、自分より寿命の短い変数の参照はどうあがいても取得できないためである。


なんかあとライフタイムが続くぽいが長くなったので分割。',1,'2017-02-23 22:27:15','2017-02-23 22:27:15');
INSERT INTO "articles" VALUES(17,'kokoro.io と私','[kokoro.io Advent Calendar 2017](https://adventar.org/calendars/2519) 3日目の記事です。前回は[pgrhoさんの記事](https://kaiita.com/_/kokoro-io-advent-calendar-day-2)でした。ｻﾞﾏﾘﾝﾎｰﾑｽﾞは黒須プラットフォームであることがわかりましたね。

kokoro.ioの機能や今後の展望などは今後の記事に譲るとして、今回の記事ではクローズドβとして公開されているkokoro.ioが今に至るまでの経緯を私が知る限りの範囲で少しばかり振り返ってみたいと思います。

# 私です
kokoro.ioの主にフロントエンドを思いついた時にいじってる程度の人間です。kokoro.io上では全然関係ない名前で存在しています。よく[プリパラチャンネル](https://kokoro.io/channels/LQD2XCEQJ)にいるのでよろしくお願いします。

# 私とkokoro.io
私がkokoro.ioの開発に携わったのはさかのぼること2016年11月頃だったと思います。当時勤めていた会社でマンネリを感じていて「Railsでも触って転職すっか〜」というモチベーションでどんなアプリを作るかと思案していたところ、唐突に[s10a](https://twitter.com/supermomonga)さんの作っていたkokoro.ioの存在を思い出しました。

その当時のkokoro.ioはまともにチャット機能が実装されておらず忘れられたオーパーツという趣で、完全に風化したプロダクトでした。

私はとりあえずアプリケーションのコードを読む前にRails5にアップグレードする作業を始めました。これが最初のきっかけです。

(コミットログをチラッと確認したところ2015年12月23日を最後のコミットに1年近く更新がなかったようです。s10aさんの孤独な戦いを伺い知れます。)

# 再び胎動し始めたkokoro.io
Rails5へのアップグレードをしたコミットによってkokoro.ioは息を吹き返す最初のきっかけを得ました。s10aさんのやる気が増えた結果、部屋の掃除などをするようになったりSlackで開発用チームが作られたりとkokoro.ioを複数の人間たちで開発していく体制が整い、デプロイ環境やCI、フロントエンドの整備が行われた時点で完全にkokoro.ioには再び血が通い始めて温度を持ち始めたと思います。

私がサーバーサイドのテストを追加したりGrapeの導入など細々とした作業をしている傍ではs10aさんや[kamichiduさん](https://twitter.com/kamichidu)が豊富な知識と技術力でいつのまにかフロンエンドやデプロイ環境の整備、チャット機能の根幹となるサーバーサイドを実装していたのは脱帽です。あまりの物事のスピードに転生して歯が生え変わるかと思いました。

そう。気づけば、kokoro.ioでリアルタイムな会話ができていたのは疑いようもない事実だったのです。

# 活発になるkokoro.io
最低限の機能を備え始めた時点でドッグフーディングを視野に入れた機能要件の議論が日々行われるようになりました。割とシームレスにSlackからkokoro.ioに移行できたので時期は全く覚えていませんが、ものすごく感動を覚えた気がします。この時点ですでにクローズドβとして全世界にインターネットされました。

先述の通り詳しい機能はそのうち記事になると思いますが、bot機能が使える状態になったことでgithubやCIの連携が実現されてもはや完全にドッグフーディストとして恥ずかしく状態になったのは記憶に新しいところです。

そして、ユーザーの受け入れがはじまりSlackのメンバーだった人間たちはもちろんのこと、VimConfなどによって大勢の新規人間たちがkokoro.ioの管理下に置かれたのはいうまでもありません。

この辺りで完全に自分の作ったものが人間の手によってバグ報告されてきていい感じになってきました。

# モバイルアプリの登場
みなさんはすでにkokoro.ioアドベントカレンダー2日目の記事を読んでいることでしょうからkokoro.ioにモバイルアプリがあることをご存知でしょう。pgrho氏が開発していて今後もアドベントカレンダーで記事を書きまくることと思いますが、pgrho氏の参加もかなりの起爆剤になっています。

モバイルアプリが出てきたことでレスポンシブ対応が不十分だったことに起因するkokoro.ioを利用するモチベーションがかなり改善されたと、少なくとも私は思っています。

また、pgrho氏からAPIのユースケースについて指摘をもらったりなんだりで品質を上げるきっかけを色々もらってる気がします。

s10aさんかpgrho氏あたりに適当に使いてえという旨を伝えればなんか使えるようになると思います。噂ではなんかするとアレできるページが特設されるような話もあるようですが、知りません。

# 得たもの
kokoro.io開発を通じてDockerとかVuejs, TypeScriptとかはものを作るのに困らない程度の知識を身につけることができた気がします。Railsは根本的にあまり興味が湧かなかったというのもあって依然よくわからないまま気が向いた時に修正とかテスト追加してるレベルですけど。

当時の職場への不満感から反骨心に近いものを原動力に手を出したものですが、結果的にはポジティブに開発がすすめられています。

皆さん、今溜まっている鬱屈としたドロドロした感情があるとしたら何かを生み出すいい機会かも知れませんよ。なんかこう、自家中毒を起こさないでヘドロを消化できる感じがしていい。

あとなんかやたら能力の高い得体の知れない人間の知り合いが微妙に増えたりして面白いです。

# kokoro.ioのこれから
技術的な課題は置いておくとして、kokoro.ioは今ある構想の機能要件のうち3割くらいしか実現できてないと思います。あとアクティブユーザーが少なすぎて内輪感も否めません。

クローズドβという立ち位置ではありますが、チャットの機能自体は普通に使えるのでコミュニケーションツールとしては最低限のラインは担保してるしガンガン使い倒してほしいという思いがあります。

残念ながら私の交流範囲は著しく狭いのでユーザーを増やすことはできませんので皆さんが広めるしかありません。あとは頼んだ。

アドベントカレンダーですが、早速明日誰も書く人がいないから今すぐ適当なチャンネルに参加してそのチャンネルについてのアレとかを記事にするとか、そういうことをしていったらいいと思います。

おわり',1,'2017-12-03 00:00:00','2017-12-03 00:00:00');
INSERT INTO "articles" VALUES(18,'kokoro.ioのAPIレスポンスエンティティ管理の妥協点','[kokoro.ioアドベントカレンダー](https://adventar.org/calendars/2519)4日目の記事です。昨日はbokuさんのアレでした。

今日は書くつもりなかったのですが、誰もかかなさそうなので思いつきで書きます。

kokoro.ioはフロントエンドとがTypeScript + VueJS, バックエンドがRuby on Railsという構成です。

サーバー側は歴史的経緯によりSPAで作っているチャット画面が問い合わせるRESTful APIサーバーとコントローラーが並存しています。

今回はkokoro.io開発にあたってAPIの設計と悩みどころと妥協点を挙げます。多分割と一般的な話だと思う。

# エンティティの循環参照
`GET /v1/channels` と `GET /v1/memberships` はお互いにチャンネルの情報とメンバーシップの情報を持っています。

そうした場合、エンティティの定義は再利用したいというのが世の常ですがナイーブに実装すると当然循環参照が起きてしまします。

そこで、以下のようなワークアラウンドで対応しています。

```ruby
class ChannelEntity < Grape::Entity
  expose :membership, ...
  ...
end

# ChannelEntity 内の membership を外す
class ChannelWithoutMembershipEntity < ChannelEntity
  unexpose :membership
end

class MembershipEntity < Grape::Entity
  expose :channel, documentation: { type: ChannelWithoutMembershipEntity, desc: ''チャンネル情報'' }, using: ChannelWithoutMembershipEntity
  ...
end
```

私が実装したのですが我ながら最悪ですね。でもこうするしかなかった。多分設計が悪いんですけど、ダルすぎてあんまり再考していません。

`MembershipEntity`にチャンネルの情報をもたせたい理由を考えてみます。

ログインユーザーが最初にチャット画面を開く瞬間、裏側では自分の参加しているチャンネル一覧を取得しに行っています。そのエンドポイントは`GET /v1/memberships`だったりします。

なぜメンバーシップを取りに行ってるかというと、ログインユーザーのメンバーシップはチャンネルに対して当然一意だからです。

問題なのはチャンネルをアクティブにした時に自分の以外のメンバーシップを取得する必要があり、そのエンドポイントが`GET /v1/channels`なのです。

チャンネルリソースに生えているメンバーシップリソースの取得という意味では理屈はあっています。なのでここもいじりようがありません。

ようはリソースの主従がはっきりしていないことが原因です。でも、ダルい。。。。。。無限に。リプレイスが計画されているようなのでそこでごっそり変えると思います。

良くなる。そう言っておきます。

ちなみに、GraphQLは？みたいな話も当然出たんですがなんとなく食指が動かないとか、あとなんかユースケースにあってなくね？みたいなところがあった気がするけど全部忘れた。

# フロントエンドのエンティティ管理
TypeScript を使っているんだから、 APIのエンティティスキーマを型としてフロントエンドでも管理したいですよね。

ただ、現状はそこまで手が回っておらずカオスです。どの程度カオスかというと

```javascript
export interface Channel {
  id: string | null;
  requestParams: {
      limit: number;
      before_id: number | null;
  };
  channel_name: string | null;
  messages: Array<Message>;
  member_id: string;
  authority: string;
  memberships: Array<Membership>;
  reachedEnd: boolean;
  nobodyPost: boolean;
  unreadCount?: number;
  kind?: ChannelKind;
  draftMessage: DraftMessage;
  transitMessagesMap: object;
  fetchingMessage: boolean;
  fetchingMemberships: boolean;
  currentScrollPosition: number;
  atScrollBottom: boolean;
  initialMessagesFetched: boolean;
  depth: number;
  displayName: string | null;
}
```

ぱっと見では伝わらないと思いますが、なぜ主キーであるidがnullableなの？とかがわかりやすいと思います。

これは、、、、、、、、ですね、、、、、、その、、、、、、、チャンネル取得前のダミーチャンネルと実態としてのチャンネルを一つのインターフェースで表現しようとしているからです。

また、APIのエンティティに存在しないプロパティが生えまくっています。

これはフロントエンドの文脈とAPIレスポンスの文脈を一つのモデルで扱おうとして起きている問題です。

ただ、まあこれに関しては鋭意直してます。修正方針は明快で、フロントエンドでも頑張ってエンティティの定義に追随しよう、フロントエンド独自のインターフェースとしてエンティティの型とは明確に分けよう。

というものです。最初からそうやれや。。。。。。。。


# これらの割れ窓が存在する理由
気合が足りません。仲間を思う気持ち、絆、思いやり、地元愛、それらの大切な要素が欠如している結果だと思います。

# 泣けるという方へ
泣きましょう。どうぞ、泣いてください。好きなだけ泣いて、全部を受け入れましょう。


〜fin〜',1,'2017-12-04 19:32:39','2017-12-04 19:32:39');
INSERT INTO "articles" VALUES(19,'kokoro.io のフロントエンド事情　','この記事は[kokoro.ioアドベントカレンダー](https://adventar.org/calendars/2519)7日目の記事です。5, 6日分が空席なので、ご自由に。

今回はkokoro.ioのフロントエンド事情についてつらつらと書きます。

先に断っておくと、フロントエンドのスペシャリストでもない(むしろ申し訳程度)し先進的な技術選択や技術的挑戦は特にしていません。

# 使用している技術要素
基本的にはTypeScript + VueJSをwebpackでES2015にトランスパイルする今では当たり前の組み合わせです。

VueJSは状態管理とSPAのラウティングを目的としてvuexとvue-routerを使用しています。UIコンポーネントは使っていません。

## なぜVueJSなのか
[kamichiduさん](https://twitter.com/kamichidu)が環境を整えてくれたからその流れでという感じです。思ったほど学習コスト高くなくていい感じです。

kokoro.ioではSFCではなくvueテンプレートとコンポーネントとスタイルを別ファイルで分けています。

下のような構成になります。

```sh
ComponentA
  - index.ts (エントリポイント)
  - ComponentA.vue (vueテンプレート)
  - ComponentA.vue.ts (コンポーネント定義)
  - style.css (スタイル)
  - ChildComponent
    - ...以下同様
```

これも歴史的経緯です。

# VueJSのはなし
VueJSはkokoro.ioで初めて触りました。それまではmithril.jsとかMariontteJSくらいしかまともに触ったFWはありませんでした。
なので色々トンチンカンなことをしでかしてます。

## vuex を誤解していた
かつて、親子関係を意識していなかったコンポーネント設計を見直すためにそれまでのpropsのバケツリレーでは限界が見えて来たので、[vuex](https://vuex.vuejs.org/ja/intro.html)導入を決めました。

仕事してるし、なんか怠けたりする必要があったのでなんだかんでvuex導入には約1ヶ月くらいかかったのですがなんとか動く感じになりました。

vuex導入に際して私は「コンポーネントの構成に合わせてvuexもネストさせなくてはいけない」という使命感に支配され、そんな風に実装して今に至ります。

ただ、私はvuexについて大きな誤解をしていました。vuexはあくまでグローバルステートをコンポーネントの階層問わずいい感じにアクセスできるようにしてくれるだけであって、それはコンポーネントの構造とは全く無関係なわけです。

kokoro.ioで言えばどんな階層からも知りたい状態として「選択中のチャンネル」(これをアクティブチャンネルと呼びます)が挙げられます。それ以外の例えばチャット表示画面の一つのメッセージを表現するコンポーネントの状態をチャンネル一覧が知る必要はありません。

コンポーネントが自分自身の状態を管理するのはdataの役目なので、つまりそういうことです。ここを履き違えるとrootレベルのactionからモジュールレベルのmutaionを呼び出したり、モジュールレベルのmutaionsにrootStateが頻発する可能性が出て来て結果的にvuexクソ！！みたいな短絡をおこしかねません。(馬鹿げていますが、本当に起きていました)

それともう一つ、管理したいのはアクティブチャンネルがなんなのかであってモデル層をどうこうするのとは切り離して考えるべきです。

意味がわからないと思いますが、チャンネルオブジェクト諸々プロパティを更新するのにaction経由でやってました。本来はモデル層にメソッドを生やしてやるべきだというのに。

```js
// actionの定義
{
  async fetchMessages({state}): {
    const resp = await state.request(state.activeChannel.id)
    resp.map(c => {
      ....
    })
  }
}
```

みたいなことをしていて、完全にクソです。
普通にコンポーネント内で

```js
  yaruzoHandler(): {
    this.activeChannel.fetchMessages()
  }
```

とかでいい。VueJS 初心者だったとかいう次元の話でもないので虚しい。　

ここではチャンネルを例に出してるけどチャンネルだけじゃないし、まあ人生いろいろあります。

### 何が言いたいのか
vuexはシンプルに使うべきです。モデル層のロジックはモデルに生やすべきだし、グローバルステートをこねくり回す責務だけ突っ込めばいい。という当たり前の結論です。すいません。

## vue-property-decorator が素晴らしい
素晴らしい。decorator はガンガン使っていきたい。みなさん有効にしましょう。現場からは以上です。

## その他
webpack は別に慣れてるので特にアレだし、TypeScriptはいいですね、としか言いようがない。今、VueJS関連で一番の関心はVueJSのUIコンポーネントです。気が熟したら[element](http://element.eleme.io/#/en-US/component/installation)か何かに乗り換えようと考えています。

Bootstrapの何が嫌かというとjQuery依存な点です。jQueryは別に嫌いじゃないですけど、依存が存在する状態自体は嫌いです。

そんなところかな。明日はpgrhoさんです。楽しみにしましょう。

おしまい',1,'2017-12-07 00:00:00','2017-12-07 00:00:00');
INSERT INTO "articles" VALUES(20,'kokoro.ioでbotを作ろう','[kokoro.ioアドベントカレンダー](https://adventar.org/calendars/2519)10日目の記事です。今回はkokoro.ioでbotを作る手順をｼｪｱｰします。

公式ドキュメントとかないのですが、そのうち作られるかもしれない。

1. botアカウント作成
1. botプログラム作成
1. botをチャンネル登録

# botアカウント作成
[ここ](https://kokoro.io/bots/new)から入力項目を満たせば完了です。ところでBot一覧とはなんでしょう？私もわかりません。

アカウントが作られるとbot用のアクセストークンが付与されるのでそいつを今後使います。

# botプログラム作成
では、早速作ってみましょう。

特に明示されていない部分ですが、現在の使用では次の2種類の方法でbotを動かすことができます。

- チャンネルのメンバーの発言に対して任意の発言をする
- 任意のタイミングまたは定時バッチで発言をする

いずれの処理も、botの発言としてはリクエストヘッダに`X-ACCESS-TOKEN=<アクセストークン>`を指定して[POST /v1/bot/channels/{channel_id}/messages](https://kokoro.io/apidoc#!/bot/postV1BotChannelsChannelIdMessages)で行います。

また、無差別なCallback urlへのリクエストが起き得るのですが、リクエストヘッダに生えている`Authorization`プロパティの値と`callback_secret`でバリデーションを行います。

bot用エンドポイントのペイロードについてはAPIドキュメント参照のこと。

## チャンネルのメンバーの発言に対して任意の発言をする
Callback urlを入力すると、botが参加しているチャンネルにおけるメンバーの発言をペイロードとしてCallback urlにリクエストが来ます。
Callback urlで待ち受けているbotがペイロードを解析して任意の処理を行うわけです。

コード例としてAPIの変更に追いついてなくて動かなくなっている[KFC bot](https://github.com/mtwtkman/kfc-kokoroio-bot/blob/master/src/main/scala/io/kokoro/bot/KfcServlet.scala#L54-L95)のコードをちょっといじって挙げてみます。

```scala
...
post("/") {  // Callback url のルートパス
  val body = parse(request.body)

  // callback_secret のバリデーション
  request.getHeader("Authorization") match {
    case x if x == callback_secret =>
    case _ => {
      logger.debug("Invalid callback_secret")
      halt(401, "Invalid callback_secret")
    }
  }

  // 発言内容のパース
  val parsed: List[(String, String)] = for {
    JObject(elem) <- body
    JField("raw_content", JString(message)) <- elem
    JField("room", JObject(room)) <- elem
    JField("id", JString(room_id)) <- room
  } yield (message, room_id)
  parsed match {
    case List((message, room_id)) if message.matches(TORI_PTN) && room_id != "" => {

      // botのリアクション作成
      val tori_message = calc_date() match {
        case Some(day) => s"次のとりの日まであと`${day}日`です"
        case None => "今日はとりの日です!今すぐとりの日パックを買いましょう!"
      }
      val req_data = s"""{
        "message": "$tori_message",
        "display_name": "KFC"
      }"""
      val url = s"${API_ENDPOINT}${room_id}/messages"
      logger.info(s"post ${tori_message} to kokoro.io")
      val resp = Http(url)
        .postData(req_data)
        .header("Content-Type", "application/json")
        .header("X-Access-Token", access_token)
        .asString
    }
    case _ => {
      logger.debug(s"Not matched with `${TORI_PTN}`")
      halt(401, "Not matched")
    }
  }
}
```

楽チンですね。

## 任意のタイミングまたは定時バッチで発言をする
これも簡単です。botのアクセストークンを使って好きなタイミングで発言したらおしまいです。

よかったですね。

# botをチャンネル登録
普通にbotのIDを指定してチャンネルに招待してやれば登録完了です。

自分の管理しているbotは[ここ](https://kokoro.io/bots)から確認できます。

# 今の仕様でできないこと
できないだけで対応しないわけではないと思います。あんまりポリシーはわかってないので詳しく知りたければ[s10aさん](https://twitter.com/supermomonga)に質問してみると何かわかるかもしれません。

## websocketのイベントが監視できない
例えばメンバーがチャンネルにjoinしたイベントをbotが捕捉することはできません。もちろん手動でwebsocketのコネクションを作って任意のチャンネルをsubscribeすれば技術的には可能です。まあでも非公式です。

## アバター画像が変更できない
`display_name`は変えられるんだけどアバター画像は変更できません。

## ホストしているbotをオーナー以外に共有ができない
1botにつき1つのcallback_secretを持ってるのでとあるbotを流用したいとなった時はbotを新規に登録してcallback_secretを発行した上でさらに、そのbotのソースコードを手に入れて自分の環境で動かさねばなりません。

# クライアントライブラリ
私の確認してる限り、`C#`と`Python`バインディングがあります。　

- [kokoro-io-net](https://github.com/kokoro-io/kokoro-io-net): pgrho氏が作ってる
- [kokoro-io-py](https://github.com/mtwtkman/kokoro-io-py): 拙作。メンテしてないので動かない可能性がめっちゃ高いのと実装いい加減なのでPRください。

一説によるとbotを作ると健康が良くなりますので、よろしくお願いします。

現場からは以上です。',1,'2017-12-10 00:00:00','2017-12-10 00:00:00');
INSERT INTO "articles" VALUES(21,'kokoro.ioを支えるプリパラ','[ko](https://adventar.org/calendars/2519)です

さて、いよいよ(あるにはあるけど)話題がなくなったしどうせ誰も読んでいないので今回はプリパラについて書きます。好きだから…

とはいえ、kokoro.ioと無関係なことを書くのは流石に気がひけるのでちゃんとkokoro.ioと関係のある話題にしているつもりです。

プリパラはkokoro.io開発になくてはならない要素でした。虚実交えつつプリパラがいかにしてkokoro.io開発を支えたかをお伝えできればと考えています。

ただし、プリパラを語りつくすのは到底無理な話なのでこの記事の目的を、重ね重ね言うようですがkokoro.ioとの関わりという観点に絞りたいと思います。

# プリパラとは
プリパラはプリティーリズムシリーズに系譜を持つアーケードゲームです。プレーヤーはライブを重ねてアイドルランクを上げ、様々なコーデやチームを組んで神アイドルを目指します。

アーケードゲームに連動して販促アニメとしてプリパラがあるわけですが、どんなメディアが展開されているかという話題自体はあくまで経済活動の一端であり即物的な話でしかありません。

本質的にはプリパラとは女の子たちの憧れです。おともだちと切磋琢磨して神アイドルとなるために努力を惜しまず、決して諦めず、心の底から楽しむためのプラットフォームです。

作中、プリパラの運営母体については明らかにされておらず、言及もされません。現代に生きる我々にとって日常生活に車が街中を走っているのと同じように作中ではプリパラが存在しているのです。

kokoro.ioを開発しているメイン開発者の[s10aさん](https://twitter.com/supermomonga)、スマホ版アプリを開発している[pgrho氏](https://twitter.com/pgrho)は重篤なプリパラファンです。

かくいう私もその一人で、2017年4月頃よりプリティーリズムシリーズ含めてプリパラにどっぷりと虜になってしまっているにわかではあるもののプリパラファンの一人です。

ここでいうプリパラファンはメディア問わずにプリパラを純粋に楽しんでいるという意味です。

# プリパラが与えるkokoro.ioへの影響
まず、影響**しない**こととして言えるのはkokoro.ioのソースコードそのものです。ガァルマゲドンが結成したからといって画像アップロード機能が実装されるわけではありません。まずこのことは断っておきます。

ここで考えられる一番の影響はハブとしての目に見えない副次的な効果です。プリパラの主な効果はアイドルたちの成長や葛藤に感化されて多面的な感情の高ぶりが挙げられます。しかしそれは一番の影響としませんでした。

なぜなら、一人の熱量を上げるよりもプリパラを介して集まった人間たちのマインドセットのグロースがシナジーを生み出し、乗数効果を持ったコミットを生み出すからであります。

ようはプリパラ見ようぜ、プリパラの曲聴こうぜと曖昧な提案によりモハに人が集まることで直接的な会話やフィードバックが発生し、なんとなく開発が進んだり溜まっていた資源ゴミが捨てられるなどの人間活動にすら介入する現象が観測されたわけです。

# プリパラの楽しみ方
プリパラは基本的に楽しいです。キャラの魅力も当然あるのですが、1期2期に関しては主人公の真中らぁらの掲げる「みんな友達、みんなアイドル」というモットーを主軸にストーリーが進むため、視聴の仕方にも一貫性が生まれます。

おそらくですが、kokoro.ioにも一貫性はあります。ここでいう一貫性とは、s10aさんの脳内である程度の仕様やユーザーが固まっているという意味で、場当たり的にその場しのぎでキャッチーな機能をなんとなく入れたのではうまくいっても何かの模倣でしかないし、そもそもユーザーが定着しないはずです。

かといって完全オリジナルというわけでもなく、いいものはいいと既存のサービスからアイデアを拝借するという柔軟さを以ってして我々は今日もプリパラとkokoro.io開発ないしはkokoro.ioでのチャットを楽しんでいるわけです。

# プリパラちょっといい話
## ぷりのままで
kokoro.io開発に首を突っ込みだした頃の私はプリパラを知らず、s10aさん宅(以下モハ)で流れる当時単なる電波ソング、あるいは空気の振動として関心もくれなかったぷりっとぱ〜ふぇくとを幾度となく耳にしました。

ぷりっとぱ〜ふぇくとという曲はらぁらと共に神アイドルを目指す南みれぃが「アイドルとしての自分」に疑問を抱きアイドルを辞める決意をする苦境を乗り越えた上で「ポップアイドルみれぃのらしさ」を凝縮した信念の塊のような楽曲です。

ある夏の出来事、いつものようにモハでぷりっとぱ〜ふぇくとを延々と耳にし帰宅した夜、私は知らぬ間にyoutubeでぷりっとぱ〜ふぇくとを検索し再生していることに気づいてしまったのです。

それからは意識的に、自然とストーリーを知らずとも私は本能的にみれぃの信念を理解し、プリパラの視聴を始めました。

プリパラの視聴を全て終える頃、私はvuexの導入に取り掛かかっていました。修正範囲があまりにも大きく、またデグレなしでイベント管理の設計もせねばならなかったあの頃は「こんなに修正コストかける意味あんのか？」と自分の作業に疑問を持っていました。

そんな折、みれぃの苦悩を思い出したわけです。みれぃは決して妥協をせずだからこそ自分のアイドルとしての適性に疑問を感じた瞬間にアイドルを辞めるという短絡とすら思える決断をしたわけです。

時にはプリパラ内外でキャラ付けをしていた自分ではファルルに勝てないと考えたみれぃはキャラを捨てて語尾のぷりを捨てようかとも考えていました。しかし結果的にキャラ付けと考えていたはずのみれぃは南みれぃ本人と切ってもきれない状態だったのです。

私はそんなみれぃを思い出して悩みの種類は全く違えど彼女の逆境を受け入れる姿勢に畏敬の念を禁じ得ず、こう決意しました。「ぷりのままで」

そうして、vuex導入は約1ヶ月の時を経て完遂されたのでした。

## トンでもSUMMER ADVENTURE
ドレッシングふらわーは私の人生に一つの節目を与えました。トンでもSUMMER ADVENTURE以前と以降です。トンでもSUMMER ADVENTUREは私にとって示唆的でした。

本来別のチームとして活動しており、互いに疎の関係であるドレッシングパフェの3人とふわり、らぁらは運命のいたずらか濁流に飲まれながらも決して諦めずお互いの手を取り助け合って思いを一つに協調した結果チーム結成しました。(お互いを高めあう好敵手という見方をしたい気持ちはわかりますが、ここではそのような観点は控えます)

疎にして協調すること、これはシステム開発も同じことが言われていますし、私もそう思います。

VueJSはコンポーネント指向のフレームワークであり、kokoro.ioでも当たり前のように役割ごとにコンポーネントを分けています。

疎であるがゆえに互いの関心を分離することでメンテナンス性と拡張性を担保するわけです。そして、自由にコンポーネントを組み合わせることで一つの大きなコンポーネントを組成することができる。

ドレッシングパフェもまたウェスト姉弟と東堂シオンという分け方で言えば出自としては疎です。お互い生まれに何も影響を及ぼしません。

このように我々は悪く言えば無関心、しかし可能な限り関係を分離しておくことで必要な時またはお互いの気持ちを一つにして協調関係を作って何倍もの効果を生みだすためには何事も疎にしておく必要があるということがわかります。

とはいうものの、kokoro.ioの文脈で言えばオープンソースのコンポーネントライブラリではないので再利用性よりも機能要件の充足を優先するべきです。

そうした場合、全てを疎にすることよりも何を実現するかに焦点を当てる必要があります。そんな時、私はキーボードから手を離しコーヒーを淹れます。

部屋にはトンでもSUMMER ADVENTUREの一節が流れます。〽︎スリルと背中合わせで上等

私は結束力という字を頭に浮かべながら密結合なコンポーネントを作る勇気を持ったのです。いくばくかのスリルを伴いながら…

# 結びに
みなさんもプリパラ、いかがですか


終わり',1,'2017-12-16 00:00:00','2017-12-16 00:00:00');

INSERT INTO "tags" VALUES(1,'rust');
INSERT INTO "tags" VALUES(2,'webpack');
INSERT INTO "tags" VALUES(3,'misc');
INSERT INTO "tags" VALUES(4,'python');
INSERT INTO "tags" VALUES(5,'mithril');
INSERT INTO "tags" VALUES(6,'javascript');
INSERT INTO "tags" VALUES(7,'kokoro.io');

INSERT INTO "taggings" (id, article_id, tag_id) VALUES(1, 1,3);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(2, 2,4);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(3, 2,6);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(4, 2,5);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(5, 2,2);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(6, 3,4);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(7, 4,4);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(8, 5,6);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(9, 6,4);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(10, 7,4);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(11, 8,4);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(12, 9,6);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(13, 10,6);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(14, 10,5);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(15, 11,6);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(16, 11,5);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(17, 12,6);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(18, 12,5);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(19, 13,6);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(20, 13,5);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(21, 14,4);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(22, 15,5);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(23, 16,1);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(24, 17,7);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(25, 18,7);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(26, 19,7);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(27, 20,7);
INSERT INTO "taggings" (id, article_id, tag_id) VALUES(28, 21,7);
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('articles',21);
COMMIT;
