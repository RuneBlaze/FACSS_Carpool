function updateBitfield(index, value) {
      
      var f = document.getElementById('final');
      var vl = eval(f.value);
      if (value) {
        vl.push(index);
        // var m = 1 << index;
        // vl = vl | m;
      } else {
        var i = vl.indexOf(index)
        vl.splice( i, 1 );
        // var m = 1 << index;
        // vl = vl ^ m;
      }

      f.value = JSON.stringify(vl);
    }
    var f = document.getElementById('final');
    f.value = "[]";