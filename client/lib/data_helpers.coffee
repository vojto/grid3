DataHelpers =
  dataForTemplate: (data) ->
    _(data).map (row, i) ->
      row = _(row).map (cell, j) ->
        {index: j, cell: cell}
      {index: i, row: row}