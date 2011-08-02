/* DO NOT MODIFY. This file was compiled Tue, 02 Aug 2011 21:33:26 GMT from
 * /Users/matt/pixie.strd6.com/app/coffeescripts/jquery.animation_editor2.coffee
 */

(function() {
  $.fn.animationEditor = function(options) {
    var Animation, Controls, animationEditor, animationNumber, animationTemplate, animations, controls, currentAnimation, editorTemplate, frameTemplate, spriteTemplate, templates, updateUI;
    animationNumber = 1;
    animationEditor = $(this.get(0)).addClass("editor animation_editor");
    templates = $("#animation_editor_templates");
    editorTemplate = templates.find('.editor.template');
    animationTemplate = templates.find('.animation');
    spriteTemplate = templates.find('.sprite');
    frameTemplate = templates.find('.frame');
    Controls = function() {
      var changePlayIcon, fps, fpsEl, intervalId, scrubber, scrubberEl, self, update, updateFrame;
      intervalId = null;
      scrubberEl = animationEditor.find('.scrubber');
      scrubber = {
        min: scrubberEl.get(0).min,
        max: scrubberEl.get(0).max,
        val: scrubberEl.val()
      };
      fpsEl = animationEditor.find('.fps input');
      fps = {
        min: fpsEl.get(0).min,
        max: fpsEl.get(0).max,
        val: fpsEl.val()
      };
      updateFrame = function() {
        update();
        scrubber.val = (scrubber.val + 1) % (scrubber.max + 1);
        return currentAnimation.currentFrameIndex(scrubber.val);
      };
      changePlayIcon = function(icon) {
        var el;
        el = $('.play');
        el.css("background-image", "url(/images/" + icon + ".png)");
        if (icon === 'pause') {
          return el.addClass('pause');
        } else {
          return el.removeClass('pause');
        }
      };
      update = function() {
        scrubberEl.val(scrubber.val);
        return scrubberEl.get(0).max = scrubber.max;
      };
      self = {
        fps: function(val) {
          if (val != null) {
            fps.val = val;
            return self;
          } else {
            return fps.val;
          }
        },
        pause: function() {
          changePlayIcon('play');
          clearInterval(intervalId);
          return intervalId = null;
        },
        play: function() {
          if (currentAnimation.frames.length > 0) {
            if (!intervalId) {
              intervalId = setInterval(updateFrame, 1000 / fps.val);
            }
            return changePlayIcon('pause');
          }
        },
        scrubber: function(val) {
          if (val != null) {
            scrubber.val = val;
            return self;
          } else {
            return scrubber.val;
          }
        },
        scrubberMax: function(val) {
          if (val != null) {
            scrubber.max = val;
            return self;
          } else {
            return scrubber.max;
          }
        },
        scrubberPosition: function() {
          return "" + scrubber.val + " / " + scrubber.max;
        },
        stop: function() {
          scrubber.val = 0;
          update();
          clearInterval(intervalId);
          intervalId = null;
          changePlayIcon('play');
          return currentAnimation.currentFrameIndex(-1);
        }
      };
      return self;
    };
    Animation = function() {
      var currentFrameIndex, findTileIndex, frames, name, self, sequences, tileset, update, updateSequence;
      tileset = {};
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/323/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/324/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/325/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/326/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/327/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/328/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/329/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/330/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/331/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/332/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/333/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/334/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/335/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/336/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/337/original.png";
      tileset[Math.uuid(32, 16)] = "http://dev.pixie.strd6.com/sprites/338/original.png";
      sequences = [];
      frames = [];
      currentFrameIndex = 0;
      name = "State " + animationNumber;
      animationNumber += 1;
      findTileIndex = function(tileSrc) {
        var src, uuid;
        for (uuid in tileset) {
          src = tileset[uuid];
          if (src === tileSrc) {
            return uuid;
          }
        }
      };
      updateSequence = function() {
        var array, sequence, sequencesEl, spriteIndex, spriteSrc, _i, _len, _results;
        sequencesEl = animationEditor.find('.sequences');
        sequencesEl.children().remove();
        _results = [];
        for (_i = 0, _len = sequences.length; _i < _len; _i++) {
          array = sequences[_i];
          sequence = $('<div class="sequence"></div>').appendTo(sequencesEl);
          _results.push((function() {
            var _j, _len2, _results2;
            _results2 = [];
            for (_j = 0, _len2 = array.length; _j < _len2; _j++) {
              spriteIndex = array[_j];
              spriteSrc = tileset[spriteIndex];
              _results2.push(spriteTemplate.tmpl({
                src: spriteSrc
              }).appendTo(sequence));
            }
            return _results2;
          })());
        }
        return _results;
      };
      update = function() {
        var frame_index, spriteSrc, _i, _len, _results;
        animationEditor.find('.frame_sprites').children().remove();
        _results = [];
        for (_i = 0, _len = frames.length; _i < _len; _i++) {
          frame_index = frames[_i];
          spriteSrc = tileset[frame_index];
          _results.push(frameTemplate.tmpl({
            src: spriteSrc
          }).appendTo(animationEditor.find('.frame_sprites')));
        }
        return _results;
      };
      self = {
        addFrame: function(imgSrc) {
          frames.push(findTileIndex(imgSrc));
          controls.scrubberMax(frames.length - 1);
          return update();
        },
        addSequenceToFrames: function(index) {
          var imageIndex, _i, _len, _ref, _results;
          _ref = sequences[index];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            imageIndex = _ref[_i];
            _results.push(self.addFrame(tileset[imageIndex]));
          }
          return _results;
        },
        addTile: function(src) {
          var spritesEl;
          tileset[Math.uuid(32, 16)] = src;
          spritesEl = animationEditor.find('.sprites');
          return spriteTemplate.tmpl({
            src: src
          }).appendTo(spritesEl);
        },
        createSequence: function() {
          sequences.push(frames.copy());
          updateSequence();
          frames.clear();
          return update();
        },
        currentFrameIndex: function(val) {
          if (val != null) {
            currentFrameIndex = val;
            self.updateSelected(val);
            return self;
          } else {
            return currentFrameIndex;
          }
        },
        frames: frames,
        name: function(val) {
          if (val != null) {
            name = val;
            return self;
          } else {
            return name;
          }
        },
        tileset: tileset,
        removeFrame: function(frameIndex) {
          var tilesetIndex;
          tilesetIndex = frames[frameIndex];
          frames.splice(frameIndex, 1);
          if ($.inArray(tilesetIndex, frames) === -1) {
            delete tileset[tilesetIndex];
          }
          return update();
        },
        updateSelected: function(frameIndex) {
          var player, tilesetIndex;
          tilesetIndex = frames[frameIndex];
          animationEditor.find('.frame_sprites img').removeClass('current');
          player = $('.player img');
          if (frameIndex === -1) {
            return player.attr('src', tileset[0]);
          } else {
            player.attr('src', tileset[tilesetIndex]);
            return animationEditor.find('.frame_sprites img').eq(frameIndex).addClass('current');
          }
        }
      };
      return self;
    };
    editorTemplate.tmpl().appendTo(animationEditor);
    controls = Controls();
    currentAnimation = Animation();
    animations = [currentAnimation];
    updateUI = function() {
      var animation, animationsEl, index, spritesEl, src, _i, _len, _ref, _results;
      animationsEl = animationEditor.find('.animations');
      animationsEl.children().remove();
      spritesEl = animationEditor.find('.sprites');
      for (_i = 0, _len = animations.length; _i < _len; _i++) {
        animation = animations[_i];
        animationTemplate.tmpl({
          name: animation.name()
        }).appendTo(animationsEl);
      }
      if (spritesEl.find('.sprite_container').length === 0) {
        _ref = currentAnimation.tileset;
        _results = [];
        for (index in _ref) {
          src = _ref[index];
          _results.push(spriteTemplate.tmpl({
            src: src
          }).appendTo(spritesEl));
        }
        return _results;
      }
    };
    updateUI();
    animationEditor.find('.play').mousedown(function() {
      if ($(this).hasClass('pause')) {
        return controls.pause();
      } else {
        return controls.play();
      }
    });
    animationEditor.find('.scrubber').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.scrubber(newValue);
      return currentAnimation.currentFrameIndex(newValue);
    });
    animationEditor.find('.stop').mousedown(function() {
      return controls.stop();
    });
    animationEditor.find('.new_animation').mousedown(function() {
      animations.push(Animation());
      currentAnimation = animations.last();
      animationEditor.find('.sequences').children().remove();
      animationEditor.find('.frame_sprites').children().remove();
      animationEditor.find('.player img').removeAttr('src');
      return updateUI();
    });
    animationEditor.find('.sprites .sprite_container').live({
      mousedown: function() {
        var imgSrc;
        imgSrc = $(this).find('img').attr('src');
        return currentAnimation.addFrame(imgSrc);
      }
    });
    animationEditor.find('.sequence').live({
      mousedown: function() {
        var index;
        index = $(this).index();
        return currentAnimation.addSequenceToFrames(index);
      },
      mouseenter: function() {
        $(this).find('.sprite_container:first-child').addClass('rotate_left');
        return $(this).find('.sprite_container:last-child').addClass('rotate_right');
      },
      mouseleave: function() {
        return $(this).find('.sprite_container').removeClass('rotate_left').removeClass('rotate_right');
      }
    });
    animationEditor.find('.frame_sprites img').live({
      mousedown: function() {
        var index;
        index = $(this).index();
        return currentAnimation.currentFrameIndex(index);
      }
    });
    animationEditor.find('.save_sequence').click(function() {
      return currentAnimation.createSequence();
    });
    animationEditor.find('.fps input').change(function() {
      var newValue;
      newValue = $(this).val();
      controls.stop();
      return controls.fps(newValue);
    });
    animationEditor.find('input.state_name').live({
      change: function() {
        var updatedStateName;
        updatedStateName = $(this).val();
        return currentAnimation.name(updatedStateName);
      }
    });
    animationEditor.find('.state_name').liveEdit();
    return animationEditor.dropImageReader(function(file, event) {
      var src;
      if (event.target.readyState === FileReader.DONE) {
        src = event.target.result;
        return currentAnimation.addTile(src);
      }
    });
  };
}).call(this);
