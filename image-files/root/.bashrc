cat <<'MSG'
                                                               
   _|_|_|   _|_|_|   _|      _|   _|_|_|         _|_|_|_|_|    
 _|           _|     _|_|  _|_|   _|    _|     _|          _|  
   _|_|       _|     _|  _|  _|   _|    _|   _|    _|_|_|  _|  
       _|     _|     _|      _|   _|    _|   _|  _|    _|  _|  
 _|_|_|     _|_|_|   _|      _|   _|_|_|     _|    _|_|_|_|    
                                               _|              
                                                 _|_|_|_|_|_|  

01010011 01001001 01001101 01000100 01000000 

MSG

echo "PHP version: ${PHP_VERSION}"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion.d/yii ]; then
    . /etc/bash_completion.d/yii
  fi
fi
