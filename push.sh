#!/bin/bash
git add .
git commit -m 'update'
git push origin master
hexo clean
hexo g
hexo d
echo done

