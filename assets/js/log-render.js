(function() {
  // Code was taken from Travis-CI source
  // ansiparse from https://github.com/mmalecki/ansiparse
  var ansiparse = function(str) {
    //
    // I'm terrible at writing parsers.
    //
    var matchingControl = null,
        matchingData = null,
        matchingText = '',
        ansiState = [],
        result = [],
        state = {},
        eraseChar;

    //
    // General workflow for this thing is:
    // \033\[33mText
    // |     |  |
    // |     |  matchingText
    // |     matchingData
    // matchingControl
    //
    // In further steps we hope it's all going to be fine. It usually is.
    //

    //
    // Erases a char from the output
    //
    eraseChar = function () {
      var index, text;
      if (matchingText.length) {
        matchingText = matchingText.substr(0, matchingText.length - 1);
      }
      else if (result.length) {
        index = result.length - 1;
        text = result[index].text;
        if (text.length === 1) {
          //
          // A result bit was fully deleted, pop it out to simplify the final output
          //
          result.pop();
        }
        else {
          result[index].text = text.substr(0, text.length - 1);
        }
      }
    };

    for (var i = 0; i < str.length; i++) {
      if (matchingControl != null) {
        if (matchingControl == '\033' && str[i] == '\[') {
          //
          // We've matched full control code. Lets start matching formating data.
          //

          //
          // "emit" matched text with correct state
          //
          if (matchingText) {
            state.text = matchingText;
            result.push(state);
            state = {};
            matchingText = "";
          }

          matchingControl = null;
          matchingData = '';
        }
        else {
          //
          // We failed to match anything - most likely a bad control code. We
          // go back to matching regular strings.
          //
          matchingText += matchingControl + str[i];
          matchingControl = null;
        }
        continue;
      }
      else if (matchingData != null) {
        if (str[i] == ';') {
          //
          // `;` separates many formatting codes, for example: `\033[33;43m`
          // means that both `33` and `43` should be applied.
          //
          // TODO: this can be simplified by modifying state here.
          //
          ansiState.push(matchingData);
          matchingData = '';
        }
        else if (str[i] == 'm') {
          //
          // `m` finished whole formatting code. We can proceed to matching
          // formatted text.
          //
          ansiState.push(matchingData);
          matchingData = null;
          matchingText = '';

          //
          // Convert matched formatting data into user-friendly state object.
          //
          // TODO: DRY.
          //
          ansiState.forEach(function (ansiCode) {
            if (ansiparse.foregroundColors[ansiCode]) {
              state.foreground = ansiparse.foregroundColors[ansiCode];
            }
            else if (ansiparse.backgroundColors[ansiCode]) {
              state.background = ansiparse.backgroundColors[ansiCode];
            }
            else if (ansiCode == 39) {
              delete state.foreground;
            }
            else if (ansiCode == 49) {
              delete state.background;
            }
            else if (ansiparse.styles[ansiCode]) {
              state[ansiparse.styles[ansiCode]] = true;
            }
            else if (ansiCode == 22) {
              state.bold = false;
            }
            else if (ansiCode == 23) {
              state.italic = false;
            }
            else if (ansiCode == 24) {
              state.underline = false;
            }
          });
          ansiState = [];
        }
        else {
          matchingData += str[i];
        }
        continue;
      }

      if (str[i] == '\033') {
        matchingControl = str[i];
      }
      else if (str[i] == '\u0008') {
        eraseChar();
      }
      else {
        matchingText += str[i];
      }
    }

    if (matchingText) {
      state.text = matchingText + (matchingControl ? matchingControl : '');
      result.push(state);
    }
    return result;
  }

  ansiparse.foregroundColors = {
    '30': 'black',
    '31': 'red',
    '32': 'green',
    '33': 'yellow',
    '34': 'blue',
    '35': 'magenta',
    '36': 'cyan',
    '37': 'white',
    '90': 'grey'
  };

  ansiparse.backgroundColors = {
    '40': 'black',
    '41': 'red',
    '42': 'green',
    '43': 'yellow',
    '44': 'blue',
    '45': 'magenta',
    '46': 'cyan',
    '47': 'white'
  };

  ansiparse.styles = {
    '1': 'bold',
    '3': 'italic',
    '4': 'underline'
  };

  window.logRender = function(log) {
    log = log.replace(/\r\r/g, '\r')
             .replace(/\033\[K\r/g, '\r')
             .replace(/\[2K/g, '')
             .replace(/\033\(B/g, '')
             .replace(/\033\[\d+G/g, '');

    var ansi = ansiparse(log);
    return ansi.map(function(part) {
      var classes = [];

      if (part.foreground) classes.push(part.foreground);
      if (part.background) classes.push('bg-' + part.background);
      if (part.bold) classes.push('bold');
      if (part.italic) classes.push('italic');
      if (part.italic) classes.push('underline');

      return (classes.length ? '<span class=\'' + classes.join(' ') + '\'>' + part.text + '</span>' : part.text);
    }).join('');
  }

})();
