#!/bin/bash
git add .
git commit -m 'Add & Commit'
git push origin master
hexo clean
hexo g
hexo d
echo done

