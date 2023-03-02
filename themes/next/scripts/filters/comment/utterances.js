/* global hexo */

'use strict';

const path = require('path');

// Add comment
hexo.extend.filter.register('theme_inject', injects => {
  let theme = hexo.theme.config;
  if (!theme.utterances.enable) return;

  injects.comment.raw('utterances', '<div class="comments" id="utterances-container"></div>', {}, {cache: true});

  injects.bodyEnd.file('utterances', path.join(hexo.theme_dir, 'layout/_third-party/comments/utterances.swig'));

});

