<%--
  Created by IntelliJ IDEA.
  User: smaldini
  Date: 21/11/2012
  Time: 00:06
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <r:require modules="game"/>
    <meta name='layout' content='main'/>
</head>

<body>
<div class="container">
    <canvas id="testCanvas" height="400" width="960" style="border:1px solid black;"></canvas>
    <div><span id="life">20</span> Life(s)</div>
</div>

<r:script>
  var canvas;
  var stage;
  var screen_width;
  var screen_height;
  var currentPlayer;
  var players;

  var MARGIN_X = 30;
  var MARGIN_Y = 50;

  var KEYCODE_ENTER = 13;
  var KEYCODE_SPACE = 32;
  var KEYCODE_UP = 38;
  var KEYCODE_LEFT = 37;
  var KEYCODE_RIGHT = 39;
  var KEYCODE_DOWN = 40;
  var KEYCODE_W = 87;
  var KEYCODE_A = 65;
  var MOVE_LEFT = "MOVE_LEFT";
  var MOVE_UP = "MOVE_UP";
  var MOVE_DOWN = "MOVE_DOWN";
  var MOVE_RIGHT = "MOVE_RIGHT";

  window.grailsEvents = new grails.Events("${createLink(uri: '')}");

  window.game = window.game || {};
  (function () {
    var Mover = {
     moveSprite : function () {
        var _that = this;

        var collisionHandler = function (x, y) {
        if(_that.onPlayerCollision){
              for (var j in game.players) {
                if (game.players[j] != _that && game.players[j].hitRadius(_that.sprite.x + x * 4, _that.sprite.y + y * 4, game.players[j].hit)) {
                    return _that.onPlayerCollision(game.players[j]);
                }
              }
          }
          return true;
        };

        if (_that.moving) {
          var hasMoved = false;
          if (_that.sprite.currentMoves[MOVE_RIGHT] && _that.sprite.x < screen_width - MARGIN_X && collisionHandler(-1, 0)) {
            _that.sprite.x += _that.sprite.vX;
            hasMoved = true;
          }
          if (_that.sprite.currentMoves[MOVE_LEFT] && _that.sprite.x >= MARGIN_X && collisionHandler(1, 0)) {
            _that.sprite.x -= _that.sprite.vX;
            hasMoved = true;
          }
          if (_that.sprite.currentMoves[MOVE_UP] && _that.sprite.y >= MARGIN_Y && collisionHandler(0, 1)) {
            _that.sprite.y -= _that.sprite.vY;
            hasMoved = true;
          }
          if (_that.sprite.currentMoves[MOVE_DOWN] && _that.sprite.y < screen_height - MARGIN_Y && collisionHandler(0, -1)) {
            _that.sprite.y += _that.sprite.vY;
            hasMoved = true;
          }

          if(!hasMoved && _that.onWallCollision){
            _that.onWallCollision();
          }

          if(_that.onNewPosition){
            _that.onNewPosition(_that.sprite);
          }

        }

        return _that.moving;
      },

      hitRadius : function (tX, tY, tHit) {
        var that = this;
        if (tX - tHit > that.sprite.x + that.hit) {
          return;
        }
        if (tX + tHit < that.sprite.x - that.hit) {
          return;
        }
        if (tY - tHit > that.sprite.y + that.hit) {
          return;
        }
        if (tY + tHit < that.sprite.y - that.hit) {
          return;
        }

        //now do the circle distance test
        return that.hit + tHit > Math.sqrt(Math.pow(Math.abs(that.sprite.x - tX), 2) + Math.pow(Math.abs(that.sprite.y - tY), 2));
      }

    };
    var Player = function (playerName, avatar, options) {
      var that = {};

      that.hit = 24;
      that.life = 20;
      that.moving = false;

      that.text = {};
      that.imgSprite = new Image();
      that.playerName = playerName;
      that.avatar = avatar;
      that.sprite = {};


      that.initializer = function () {
        var spriteSheet = new createjs.SpriteSheet({
          // image to use
          images: [that.imgSprite],
          // width, height & registration point of each sprite
          frames: {width: 64, height: 64, regX: 32, regY: 32},
          animations: {
            MOVE_RIGHT: [10, 14, MOVE_RIGHT, 4],
            MOVE_DOWN: [15, 19, MOVE_DOWN, 4],
            MOVE_LEFT: [0, 4, MOVE_LEFT, 4],
            MOVE_UP: [5, 9, MOVE_UP, 4]
          }
        });

        //createjs.SpriteSheetUtils.addFlippedFrames(spriteSheet, true, false, false);

        that.sprite = new createjs.BitmapAnimation(spriteSheet);

        that.sprite.player = that;
        that.sprite.currentMoves = options && options.currentMoves ? options.currentMoves : {};
        that.sprite.name = that.playerName;
        that.sprite.vX = 2;
        that.sprite.vY = 2;
        that.moving =  that.sprite.currentMoves.length > 0;
        that.sprite.x = options && options.x ? options.x : Math.random() * (canvas.width - MARGIN_X) + MARGIN_X;
        that.sprite.y = options && options.y ? options.y : Math.random() * (canvas.height - MARGIN_Y) + MARGIN_Y;
        that.sprite.currentFrame = Math.floor(Math.random() * 20);

        that.hitRadius = function(tx,ty,thit){
            return Mover.hitRadius.apply(that,[tx,ty,thit]);
        };
        that.moveSprite = that.sprite.tick = function(){
            return Mover.moveSprite.apply(that);
        };

        that.text = new createjs.Text(
                that.sprite.name,
                'bold 12px Arial',
                '#000'
        );


        that.text.x = that.sprite.x - 20;
        that.text.y = that.sprite.y - 50;


        stage.addChild(that.sprite);
        stage.addChild(that.text);

        if (options && options.onload) {
          options.onload(that);
        }

        stage.update();

      };

//      that.onPlayerCollision = function(){
//        that.moving = false;
//        that.sprite.stop();
//        return false;
//      };

      that.onNewPosition = function(){
        that.text.x = that.sprite.x - 20;
        that.text.y = that.sprite.y - 50;
      };


      that.stopFiring = function (local) {
        that.firing = null;
      };

      that.fire = function (local) {
      if(!local && that.firing){
        return;
      }

      if(!local){
                grailsEvents.send('fire', {
                    playerName:that.playerName,
                    currentMoves:that.sprite.currentMoves,
                    x:that.sprite.x,
                    y:that.sprite.y,
                    action:'firing'
                });
        }

        that.firing = new game.Missile(that);
      };



      that.move = function (direction, local) {
        if(!that.sprite.gotoAndPlay){
            return false;
        }

        if(that.sprite.currentMoves[direction]){
            return;
        }

        that.sprite.gotoAndPlay(direction);
        that.sprite.currentMoves[direction] = true;
        that.moving = true;

        if(!local){
          grailsEvents.send('move', {
              playerName:that.playerName,
              currentMoves:that.sprite.currentMoves,
              x:that.sprite.x,
              y:that.sprite.y,
              action:'moving',
              direction:direction
          });
        }
      };

      that.fixPosition = function(data){
              that.sprite.x = data.x;
              that.sprite.y = data.y;
              that.text.x = that.sprite.x - 20;
              that.text.y = that.sprite.y - 50;
      };

      that.takeDamage = function(){
          that.life = that.life - 1;
          if(that.onDamage){
            that.onDamage(that.life);
          }
      };

      that.resetMove = function (direction, data) {
        if(!data){
              grailsEvents.send('move', {
                    playerName:that.playerName,
                    currentMoves:that.sprite.currentMoves,
                    x:that.sprite.x,
                    y:that.sprite.y,
                    action:'stop',
                    direction:direction ? direction : that.sprite.currentAnimation
              });
        }

        if (!direction) {
          for (var entry in that.sprite.currentMoves) {
            that.sprite.currentMoves[entry] = false;
          }
          that.moving = false;
          return;
        }

        that.sprite.currentMoves[direction] = false;
        var stop = false;
        for (var entry in that.sprite.currentMoves) {
          if (that.sprite.currentMoves[entry]) {
            that.sprite.gotoAndPlay(entry);
          }
          stop = stop || that.sprite.currentMoves[entry];
        }
        that.moving = stop;
        if (!stop) {
          that.sprite.stop();
        }
      };

      //trigger load
      that.imgSprite.onload = that.initializer;
      that.imgSprite.src = "${resource(dir: 'images/animation', file: 'Sprite_Boy.png')}";

      return that;
    };

    var Missile = function (source) {
        var that = {};
        that.source = source;
        that.moving = true;
        that.sprite = new createjs.Text(
                "*",
                'bold 16px Arial',
                '#A0A'
        );
        that.sprite.vY = 3;
        that.sprite.vX = 3;
        that.hit = 2;
        that.sprite.currentMoves = {
            MOVE_DOWN:source.sprite.currentMoves[MOVE_DOWN],
            MOVE_UP:source.sprite.currentMoves[MOVE_UP],
            MOVE_LEFT:source.sprite.currentMoves[MOVE_LEFT],
            MOVE_RIGHT:source.sprite.currentMoves[MOVE_RIGHT]
        };
        that.sprite.currentMoves[source.sprite.currentAnimation] = true;

        that.moveSprite = that.sprite.tick = function(){
            Mover.moveSprite.apply(that);
        };

        if (source.sprite.currentAnimation == MOVE_UP || source.sprite.currentAnimation == MOVE_DOWN) {
          that.sprite.y = source.sprite.y + that.hit * (source.sprite.currentAnimation == MOVE_UP ? -1 : 1);
          that.sprite.x = source.sprite.x;
        }
        if (source.sprite.currentAnimation == MOVE_LEFT || source.sprite.currentAnimation == MOVE_RIGHT) {
          that.sprite.x = source.sprite.x + source.hit * (source.sprite.currentAnimation == MOVE_LEFT ? -1 : 1);
          that.sprite.y = source.sprite.y;
        }

        that.onWallCollision = function(){
            that.onPlayerCollision();
        };

        that.onPlayerCollision = function(player){
            var idx;

            if(player == that.source){
                return true;
            }

            that.moving = false;
            for(var m in game.missiles){
                if(game.missiles[m] == that){
                    idx = m;
                    break;
                }
            }
            if(idx){
                delete game.missiles[idx];
            }

            if(player){
               player.takeDamage();
            }

            stage.removeChild(that.sprite);
            return false;
        };

        game.missiles.push(that);
        stage.addChild(that.sprite);

        return that;
    };

    game.Player = Player;
    game.Missile = Missile;
  })();

  document.onkeydown = handleKeyDown;
  document.onkeyup = handleKeyUp;

  function handleKeyUp(e) {
    if (!e) {
      e = window.event;
    }
    switch (e.keyCode) {
      case KEYCODE_LEFT:
        currentPlayer.resetMove(MOVE_LEFT);
        break;
      case KEYCODE_RIGHT:
        currentPlayer.resetMove(MOVE_RIGHT);
        break;
      case KEYCODE_UP:
        currentPlayer.resetMove(MOVE_UP);
        break;
      case KEYCODE_DOWN:
        currentPlayer.resetMove(MOVE_DOWN);
        break;
      case KEYCODE_SPACE:
        currentPlayer.stopFiring();
        break;

    }

  }


  function handleKeyDown(e) {
    if (!e) {
      e = window.event;
    }
    switch (e.keyCode) {
      case KEYCODE_LEFT:
        currentPlayer.move(MOVE_LEFT);
        break;
      case KEYCODE_RIGHT:
        currentPlayer.move(MOVE_RIGHT);
        break;
      case KEYCODE_UP:
        currentPlayer.move(MOVE_UP);
        break;
      case KEYCODE_DOWN:
        currentPlayer.move(MOVE_DOWN);
        break;
      case KEYCODE_SPACE:
        currentPlayer.fire();
        break;
    }
    //return false;
  }

  function init() {
    canvas = document.getElementById("testCanvas");

    stage = new createjs.Stage(canvas);

    screen_width = canvas.width;
    screen_height = canvas.height;

    createjs.Ticker.useRAF = true;
    createjs.Ticker.setFPS(60);

    currentPlayer = new game.Player("${params.playerName ?: 'anonymous'}", "Boy", {onload:function(){
        currentPlayer.resetMove(currentPlayer.sprite.currentAnimation);
        window.onblur = function(){
            currentPlayer.resetMove(currentPlayer.sprite.currentAnimation);
        };
        window.onunload = function(){
        grailsEvents.send('leave', {playerName:currentPlayer.playerName});
        };
    }});

    currentPlayer.onDamage = function(){
        if(currentPlayer.life <= 0){
            grailsEvents.send('leave', {playerName:currentPlayer.playerName});
            window.location.href = 'http://heyyeyaaeyaaaeyaeyaa.com/';
          }else{
            $('#life').html(currentPlayer.life);
        }
    };

    game.players = [currentPlayer];
    game.missiles = [];

    grailsEvents.on('leave',function(data){
      var targetPlayer;
      for(var i in game.players){
        if(game.players[i].playerName == data.playerName){
            targetPlayer = i;
            break;
        }
      }
      stage.removeChild( game.players[targetPlayer].sprite);
      stage.removeChild( game.players[targetPlayer].text);
      delete game.players[targetPlayer];

    });

    grailsEvents.on('move',function(data){
      var targetPlayer;
      for(var i in game.players){
        if(game.players[i].playerName == data.playerName){
            targetPlayer = game.players[i];
            break;
        }
      }
      if(!targetPlayer){
          targetPlayer = new game.Player(data.playerName, "Boy", data);
          game.players.push(targetPlayer);
      }

      if(targetPlayer != currentPlayer){
          if(data.action == "moving"){
              targetPlayer.move(data.direction, true);
          }else if(data.action == "stop"){
              targetPlayer.resetMove(data.direction, data);
          }
          if(data && targetPlayer.hitRadius && !targetPlayer.hitRadius(data.x, data.y, 50)){
            targetPlayer.fixPosition(data);
          }
      }
    });

    grailsEvents.on('fire',function(data){
      var targetPlayer;
      for(var i in game.players){
        if(game.players[i].playerName == data.playerName){
            targetPlayer = game.players[i];
            break;
        }
      }

      if(targetPlayer != currentPlayer){
        targetPlayer.fire(true);
      }


    });

    createjs.Ticker.addListener(function () {
        for (var i in game.players) {
            if(game.players[i].moveSprite){
                game.players[i].moveSprite();
            }
        }
        for (var i in game.missiles) {
            game.missiles[i].moveSprite();
        }
    stage.update();



    //robots
%{--var directions = [MOVE_LEFT, MOVE_RIGHT, MOVE_DOWN, MOVE_UP];--}%
%{--var timeout = function (robot) {--}%
%{--robot.resetMove();--}%
%{--robot.move(directions[Math.floor(Math.random() * 4)]);--}%
%{--setTimeout(function () {--}%
%{--timeout(robot);--}%
%{--}, Math.floor(Math.random() * 3000));--}%
%{--};--}%

%{--var robot1 = new game.Player("robot1", "Girl", timeout);--}%
%{--var robot2 = new game.Player("robot2", "Girl", timeout);--}%
%{--var robot3 = new game.Player("robot3", "Girl", timeout);--}%
%{--var robot4 = new game.Player("robot4", "Girl", timeout);--}%


});

}
init();
</r:script>
</body>
</html>