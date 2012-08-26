#!/bin/bash
thin -C config/thin/development_config.yml -R config/config.ru start
