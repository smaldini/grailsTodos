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

  window.grailsEvents = new grails.Events("${createLink(uri: '')}", {transport:'sse',logLevel:"debug"});

  window.game = window.game || {};
  (function () {
    var Player = function (playerName, avatar, options) {
      var that = {};

      that.imgSprite = new Image();
      that.playerName = playerName;
      that.avatar = avatar;
      that.text = {};
      that.bmpAnimation = {};

      that.hit = 24;
      that.moving = false;


      that.imgSprite.onload = function () {
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


        createjs.SpriteSheetUtils.addFlippedFrames(spriteSheet, true, false, false);

        that.bmpAnimation = new createjs.BitmapAnimation(spriteSheet);
        that.bmpAnimation.shadow = new createjs.Shadow("#454", 0, 5, 4);

        that.bmpAnimation.player = that;
        that.bmpAnimation.currentMoves = options && options.currentMoves ? options.currentMoves : {};
        that.bmpAnimation.name = that.playerName;
        that.bmpAnimation.vX = 2;
        that.bmpAnimation.vY = 2;
        that.moving =  that.bmpAnimation.currentMoves.length > 0;
        that.bmpAnimation.x = options && options.x ? options.x : Math.random() * (canvas.width - MARGIN_X) + MARGIN_X;
        that.bmpAnimation.y = options && options.y ? options.y : Math.random() * (canvas.height - MARGIN_Y) + MARGIN_Y;
        that.bmpAnimation.currentFrame = Math.floor(Math.random() * 20);
        that.bmpAnimation.tick = that.moveSprite;

        that.text = new createjs.Text(
                that.bmpAnimation.name,
                'bold 12px Arial',
                '#000'
        );


        that.text.x = that.bmpAnimation.x - 20;
        that.text.y = that.bmpAnimation.y - 50;


        stage.addChild(that.bmpAnimation);
        stage.addChild(that.text);
        if (options && options.onload) {
          options.onload(that);
        }

        stage.addChild(that.container);
        stage.update();

      };

      that.moveSprite = function () {

        var collisionHandler = function (x, y) {
          for (var j in game.players) {
            if (game.players[j] != that && that.hitRadius(game.players[j].bmpAnimation.x + x * 4, game.players[j].bmpAnimation.y + y * 4, game.players[j].hit)) {
              that.moving = false;
              that.bmpAnimation.stop();
              return false;
            }
          }
          return true;
        };

        if (that.moving) {

          if (that.bmpAnimation.currentMoves[MOVE_RIGHT] && that.bmpAnimation.x < screen_width - MARGIN_X && collisionHandler(-1, 0)) {
            that.bmpAnimation.x += that.bmpAnimation.vX;
          }
          if (that.bmpAnimation.currentMoves[MOVE_LEFT] && that.bmpAnimation.x >= MARGIN_X && collisionHandler(1, 0)) {
            that.bmpAnimation.x -= that.bmpAnimation.vX;
          }
          if (that.bmpAnimation.currentMoves[MOVE_UP] && that.bmpAnimation.y >= MARGIN_Y && collisionHandler(0, 1)) {
            that.bmpAnimation.y -= that.bmpAnimation.vY;
          }
          if (that.bmpAnimation.currentMoves[MOVE_DOWN] && that.bmpAnimation.y < screen_height - MARGIN_Y && collisionHandler(0, -1)) {
            that.bmpAnimation.y += that.bmpAnimation.vY;
          }
          that.text.x = that.bmpAnimation.x - 20;
          that.text.y = that.bmpAnimation.y - 50;

        }

        return that.moving;
      };

      that.fire = function (local) {

      if(!local){
                grailsEvents.send('fire', {
                    playerName:that.playerName,
                    currentMoves:that.bmpAnimation.currentMoves,
                    x:that.bmpAnimation.x,
                    y:that.bmpAnimation.y,
                    action:'firing'
                });
        }

        var text = new createjs.Text(
                "LOL",
                'bold 16px Arial',
                '#A0A'
        );
        if (that.bmpAnimation.currentAnimation == MOVE_UP || that.bmpAnimation.currentAnimation == MOVE_DOWN) {
          text.y = that.bmpAnimation.y + that.hit * (that.bmpAnimation.currentAnimation == MOVE_UP ? -1 : 1);
          text.x = that.bmpAnimation.x;
        }
        if (that.bmpAnimation.currentAnimation == MOVE_LEFT || that.bmpAnimation.currentAnimation == MOVE_RIGHT) {
          text.x = that.bmpAnimation.x + that.hit * (that.bmpAnimation.currentAnimation == MOVE_LEFT ? -1 : 1);
          text.y = that.bmpAnimation.y;
        }
        stage.addChild(text);
        stage.update();
      };

      that.hitRadius = function (tX, tY, tHit) {
        if (tX - tHit > that.bmpAnimation.x + that.hit) {
          return;
        }
        if (tX + tHit < that.bmpAnimation.x - that.hit) {
          return;
        }
        if (tY - tHit > that.bmpAnimation.y + that.hit) {
          return;
        }
        if (tY + tHit < that.bmpAnimation.y - that.hit) {
          return;
        }

        //now do the circle distance test
        return that.hit + tHit > Math.sqrt(Math.pow(Math.abs(that.bmpAnimation.x - tX), 2) + Math.pow(Math.abs(that.bmpAnimation.y - tY), 2));
      };

      that.move = function (direction, local) {
        if(!that.bmpAnimation.gotoAndPlay){
            return false;
        }

        that.bmpAnimation.gotoAndPlay(direction);
        that.bmpAnimation.currentMoves[direction] = true;
        that.moving = true;

        if(!local){
          grailsEvents.send('move', {
              playerName:that.playerName,
              currentMoves:that.bmpAnimation.currentMoves,
              x:that.bmpAnimation.x,
              y:that.bmpAnimation.y,
              action:'moving',
              direction:direction
          });
        }
      };

      that.fixPosition = function(data){
              that.bmpAnimation.x = data.x;
              that.bmpAnimation.y = data.y;
              that.text.x = that.bmpAnimation.x - 20;
              that.text.y = that.bmpAnimation.y - 50;
      };

      that.resetMove = function (direction, data) {
        if(!data){

              grailsEvents.send('move', {
                    playerName:that.playerName,
                    currentMoves:that.bmpAnimation.currentMoves,
                    x:that.bmpAnimation.x,
                    y:that.bmpAnimation.y,
                    action:'stop',
                    direction:direction ? direction : that.bmpAnimation.currentAnimation
              });
        }

        if (!direction) {
          for (var entry in that.bmpAnimation.currentMoves) {
            that.bmpAnimation.currentMoves[entry] = false;
          }
          that.moving = false;
          return;
        }

        that.bmpAnimation.currentMoves[direction] = false;
        var stop = false;
        for (var entry in that.bmpAnimation.currentMoves) {
          if (that.bmpAnimation.currentMoves[entry]) {
            that.bmpAnimation.gotoAndPlay(entry);
          }
          stop = stop || that.bmpAnimation.currentMoves[entry];
        }
        that.moving = stop;
        if (!stop) {
          that.bmpAnimation.stop();
        }
      };

      //trigger load
      that.imgSprite.src = "${resource(dir:'images/animation', file:'Sprite_Boy.png')}";

      return that;
    }
    game.Player = Player;
  })();

  document.onkeydown = handleKeyDown;
  document.onkeyup = handleKeyUp;

  function handleKeyUp(e) {
    if (!e) {
      var e = window.event;
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
    }

  }


  function handleKeyDown(e) {
    if (!e) {
      var e = window.event;
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
        currentPlayer.resetMove(currentPlayer.bmpAnimation.currentAnimation);
        window.onblur = currentPlayer.resetMove;
        window.onunload = function(){
                grailsEvents.send('leave', {playerName:currentPlayer.playerName});
        };
    }});

    game.players = [currentPlayer];

    grailsEvents.on('leave',function(data){
      var targetPlayer;
      for(var i in game.players){
        if(game.players[i].playerName == data.playerName){
            targetPlayer = i;
            break;
        }
      }
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
          if(data && !targetPlayer.hitRadius(data.x, data.y, 10)){
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

      targetPlayer.fire(true);
    });

    createjs.Ticker.addListener(function () {
        for (var i in game.players) {
        game.players[i].moveSprite();
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