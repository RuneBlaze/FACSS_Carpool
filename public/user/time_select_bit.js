function updateBitfield(index, value) {
      console.log(value);
      var f = document.getElementById('final');
      var vl = parseInt(f.value);
      if (value) {
        var m = 1 << index;
        vl = vl | m;
      } else {
        var m = 1 << index;
        vl = vl ^ m;
      }

      f.value = vl;
    }
    var f = document.getElementById('final');
    f.value = "0";