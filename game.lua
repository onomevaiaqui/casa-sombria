-- Teste 3.2: fundo e mascara em bitmap, entregador em 3D.
local function decode(encoded)
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local digits, parts = {}, {}
for i = 1, #alphabet do digits[alphabet:sub(i,i)] = i-1 end
for i = 1, #encoded, 4 do
    local a,b,c,d = encoded:sub(i,i),encoded:sub(i+1,i+1),encoded:sub(i+2,i+2),encoded:sub(i+3,i+3)
    local first = digits[a]*4 + math.floor(digits[b]/16)
    local second = (digits[b]%16)*16 + math.floor((digits[c] or 0)/4)
    local third = ((digits[c] or 0)%4)*64 + (digits[d] or 0)
    parts[#parts+1] = c == "=" and string.char(first)
        or (d == "=" and string.char(first,second) or string.char(first,second,third))
end
return table.concat(parts)
end
local detailedBackground = decode("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")
local detailedSofa = decode("MkE1QXA2QTtBODxBU0EyV0FZQTJaQV1BcGRBZ0ESL0IwQhUxQjtCLDxCWUIrWkJoQikuQzBDFTFDO0MsPENZQytaQ2hDKWlDa0MYLkQwRBIxRDtELDxEWUQrWkRoRClpRGxEGC1FMEUSMUU7RSw8RVlFK1pFaEUpaUVsRRgtRjBGEjFGO0YsPEZZRitaRmhGKWlGbEYYLUcwRxIxRztHLDxHWUcrWkdoRylpR2xHGG1HbUclLEgsSDUtSDBIEjFIO0gsPEhZSCtaSGxIKW1IbUglKUkwSS4xSTtJLDxJWUkrWklsSSltSXZJLnhJeEksekl6SSwoSjBKLjFKO0osPEpZSitaSmxKKW1Kd0oueEp6Six7SntKGCZLJks4J0sqS24rSzVLLjZLO0ssPEtZSytaS2hLKWlLd0tueEt7SxMmTCZMOCdMLEwVLUw1TC42TDtMLDxMWUwrWkxoTClpTHdMbnhMe0wTJk0mTTgnTSxNFS1NMk1uM007TSw8TUpNK0tNWU0VWk1oTSlpTXdNbnhNe00TJk4mTjgnTjlOFTpOO04SPE5KTitLTllOLlpOaE4paU53Tm54TntOEyZPJk84J085TxU6T2hPLmlPd09ueE97TxMmUCZQOidQOVAVOlBoUC5pUHdQbnhQe1ATJ1E5URU6UWhRLmlRd1FueFF7URMnUjlSFTpSaFIuaVJ3Um54UnxSEydTO1MVPFNKUyxLU1lTK1pTaFMuaVN3U254U3xTEydUO1QVPFRZVClaVHdUbnhUfFQTJ1UsVRMtVTtVFTxVWVUpWlV3VW54VXxVEydWLFYTLVY7VhU8VllWKVpWd1ZueFZ8VhMnVyxXEy1XO1cVPFdKVxNLV1lXKVpXd1dueFd8VxMnWCxYEy1YO1gVPFhKWBNLWGhYEmlYd1hueFh8WBMnWSxZEy1ZO1kVPFlKWRNLWWhZEmlZd1kReFl8WRMnWixaEi1aMVoTMlpZWhVaWmhaFGlafFoTJ1ssWxItWzFbEzJbWVsVWltoWxRpW3xbEydcLFwSLVwxXBMyXFlcFVpcaFwUaVx3XBV4XHxcEyddLF0SLV0xXRMyXVldFVpdaF0UaV13XRV4XXxdEydeLF4FLV4xXhMyXlleFVpeaF4UaV53XhV4XnxeEydfLF8FLV8xXwcyX1lfFVpfaF8UaV93XxV4X3xfEyhgKWB3LGAsYC0tYC1gBy9gMWAHMmBZYBVaYGhgFGlgd2AVeGB8YBMxYUphB0thd2FreGF5YRNHYkdiKkpiSmIqTmJOYhxRYlFiHFRiVWIcV2JYYhxbYltiYl5iX2JiYWJiYmJkYmhiYmliaWIba2J3Yhs=")
local detail, previousDetail = true, false
local gridPatches
if type(ui.grid) == "function" then
    local pixels = decode("2FgBW1tbW1tbW1h+fn5+fn5+fn47DGkMCQwJW1tbW1tbW1h+fn5+fn5+fld+Hh4eHgxpfldYWFhaWlhYWH5+fn5+fld+Hh5pDAkMfn5+fn5+fltbW1tbWVlZWVdXHR4eDAkMfn5+fn5+fltbW1tbW1tbW1tbPWxsbGxsfn5+fn5+V1tbW1tbW1tbW1tbPj09PT09fn5+fn5+V1tbW1tbW1tbW1tbcD09PX89V1dXV35+V1tbW1tbW1tbW1tbcD09PT1/W1tbW1tbWVdaWVpZWVtbW1tbWj09PT09W1tbW1tbWn5+fn5+fn5+V1dZcGw9PT09W1tbW1tbWn5+fn5+fn5+fn5+fgwMHh4eW1tbW1tbWX5+fn5+fn5+fn5+fh4MDAwJW1tbW1tbWX5+fn5+fn5+fn5+fh0MDAwMW1tbW1tbV35+fn5+fn5+fn5+fn0MDAwMV1paWlpbV35+fn5+fn5+fn5+fjsMHgwJfn5+fn5+WVpaV35+fn5+fn5+fjsMDAwMfn5+fn5+WVtbW1tbW1pZWVlwV34eHgwMfn5+fn5+WVtbW1tbW1tbW1tbW1o9PWxsfn5+fn5+WltbW1tbW1tbWVpZWVo9PT09fn5+fn5+WVtbW1tbWVpZWVpZWlo9PT09zFgBW1tbW1t+fn9+f39ZcFuCW1tbW1tbW1tbW1tbW1p+fzs7fX19f35+flhYWFhaW1taW1tbW35+f387fTt9fn5+fn5+V35+V35+W1tbWX59fX19fX19fn5+fn5+fn5+fn5+W1tbfjsefX0dfX1+WH5+fn5+fn5+fn5+fn5+Wn49f399O31+fn5+fn5+fn5+fn5+fn5ZWnBwcHBwcFpaWllaV1dXV35+fn5+fn5acHBaRHBERFtbW1tbW1tbW1taWlpZfn5acERaXERaWltbW1tbW1tbW1tbW1tbfnBwcFpaWkRaW1uCW1tbW1tbW1tbW1tbf01wTVpaRFpwW1tbW1tbW1tbW1tbW1tbPX5wWlpwcFpaW1tbW1tbW1tbW1tbW1tbf319fX19O39XWlpZW1tbW1tbW1tbW1tbfX19fX19fTt+fn5+fn5YWFhaWlpaW1tbHn19fR4efX5+fn5+fn5+fn5+fn5+fn5+HR4efR59O35+fn5+fn5+fn5+fn5+fn5+Hh4eHh59fn5+fn5+fn5+fn5+fn5+fn5+Hh59fR47fn5+fn5+fn5+fn5+fn5+fn5+Hh4eHX1/fn5+fn5+fn5+fn5+fn5+fn5+cD49f39+fn5+fn5+fn5+fn5+fn5+fn5+zE4BV35+fn5+fn5+fn5+fn5+fn5+V1d+fn5+fn5+V1dXV1dXV1dXfn5+fn5+fn5+fn5+HQkJHR19Ojo7O35+fn5+V1dXV1dXV1d/HR0dHR0JCQkJCQkJCQkdHXFxcTs7O35+HR0dHR0dHR0dHR0dHR0dCQkdHQkJCQkJHR0JHh4eHh4dHR0dHR0dHR0dHR0dHR0dcH5wf39/f30eHh0eHh4dHh4dHgkdHR0dgluCgoJbW1tbW3BacHBwf399bB59fX19WltbW1tbgoKCW1uCgoJaWlpaWluCWltZW4KCgoKCgoKCW1uCgltaWltbW4KCgoJbW1uCgluCgoJbW4KCW1paWlpaW1tbgoJbW1uCW4JbW1tbWFhYcH9wcHBbW1tbW4JbW1tbW1tbW1tafn5/fX19fX9YWFhYWFtbW1uCW1tbW1tYfn5/f39/fX5YWFhYWFhYW1tbgoKCW1p+fn99fTs7f1hYWFhYWFhYV35XV1dYWFpbWz5/f39/flhYWFhYWFhYfldXV35+fltbW1twWlpaW1tbW1pbWlhYfld+fn5+WltbWlpaWlpbW1tbW1tbW1tbfn5+fn5+W1twWlpaWlqCW1tbW1tbW1tbW1taWHBwW1paWlpbW1tbW1tbW1tbgltbhE4BDAwMDA0MCQweIiYmfEVFRXp6JiYwMCImJiZsIg0NImt5fEVFRUVFRUVFfEVFRXomRUUwIh4NDAwMHiIiImwmJiYmJjAmIiIMRUUwIh4NDAwMHiIiImwmJiYmJjAmIiIMZgwMDAwNDA0NDQ0MDAwMDAwNInkweXl5IiIeHh4NDAwMDAwMDA0iIjBFRUVFRUVFIiIeHh4NDAwMDAwMDA0iIjBFRUVFRUVFQkVFRXpFJiYmJjAiDSImMCYmJnlFfHwwR0dHQkdFRUV5JiIeDR4MDAwMDR4NDQ0NR0dHQkdFRUV5JiIeDR4MDAwMDR4NDQ0NJnx7RXxFJiIeDAwMCQwMDGgNDR4NDQ0MDB5rRUVHRXx8R0VFeyYwJiIiHg0NDQ0NDB5rRUVHRXx8R0VFeyYwJiIiHg0NDQ0NRUd8R0dFfEhISEh4eEdHRUVFRUdFIgwifEhISEh4eEhFfEUmenpFMHxFRSZuHg0MIiImJiZFRXp5JjBFfHx8fCYiDQ0NDQ0NIiImJiZFRXp5JjBFfHx8fCYiDQ0NDQ0NDQ0NDAwNDR4eHiIiIiZ5Ig0NDQ0MDAwMZg1mZg0NDQ0MaAwifEd4eEdHRUUmbCYiZg1mZg0NDQ0MaAwifEd4eEdHRUUmbCYihBIBEREREBERERESFBQUEhIUFBISFBISEhISEhISEhIUFBQUEhISEREQEBAQEA4FEBAQERISEREREBAQDgUOBQUFDg4OBQ4OBRAQDgUFEBAQEBAOEA4FDhAQEBAQEBAQEA4QEBAODhAQEBAQEBAQEBAREREWFhYWFhoWEBAQEBAQERAWFhcXFxsaG2BgLmtra2suFxcXGhwaGxsbGhxgYGtra2tgYBoaGhobLi4uLmAaGhoaGhoXHBxra2sca2tra2trGhoaGhoXHBwbFxdmZmVlZWgGBgZlZWVmGhoXFxwcFxYQBgZqampqampqBmpqampqHBoXGhcQagYGampqampqamoGagZqampqYBwcFgYGBmpqagYGampqBgYGBgYGampqLhwcBwZqagYGBgYGBgYGBgYGBgYGBgZqYBwcZgYGBgYGZQYGBgYGBgYGBmoGampqHBwcaAZlaBYWHGsua2suLi8vLmtra2tnHBwuZmZrLi4vLzVySEpMTHd3d0xMd0xMHBcaZi8vNUxMd3d3d3d3d3d3d3d3d3d3BwcDaDUuTHd3d3d3d3d3d3d3d3d3d3d3BAQEBWsvTHd3d3d3d3d3d3d3d3d3d3d3BAQFBRAveHd3d3d3d3d3d3d3d3d3d3d32E4Bfn5+fn5+fn5+fn5+fn5+fh0MaWkMHh5sfn5+fn5+fn5+fn5+fn5+fgkMaWkMHh5sf35+fn9/f39/f35/fn5+fh0MaWlpHh5sfldXV1dXV1dXV35+fn5+fh0MaWlpaR5sCQkdHXFxOzt+fn5+V1dXVx0MaQwJaQlpHQkJCQkJCQkJCQkJHR1xcR0MaWkJaQlqHR0dHR0dHR0dHR0dHR0JCQkMDGkJaWkHfR4eHR4dHR4eHR4dHR0dDGlpCQkJCQkGRHBwf387bH1sfWx9Hh4eHmlpaQkJCQkGgoKCW1tbW1pZWVl/Ozp9HR0JHgkJCQkHgoJbW1uCgluCgoJbW1tZWzsJHh4JCQlqW1tbW1tbW4KCW1taWlpZW34MaQkMDAkJW1tbW1tbgoKCW1tbW1tZW34MHgkJCQkJWFhYWFhYWFtbW1tbW1tbW3AJDAwJCQkJWFhYWFhYWFpbW1tbW1tbW1lsbGxuHh4eWFhYWFhYWFpbW1tbW1tbW1s9PT09PT1/WFhXWFhYWFtbW1tbW1tbW1s+PT09PT1sW1tbW1paWltbW1tbW1tbW1twPT09fz1sW1tbW1tbW1d+fn5+V1dXWVl+bGxsbD09W1tbW1tbW1h+fn5+fn5+fn47CQwMCQwenE4BHgkJCQkJaQcHBwcHBwcHB2UHBwcHB2UHCQkJCQkJCQkJaAkJCQlqaGgFBwcHB2UHLiZra2siIiJmHh5oCWhmJhwFBwcHBwcHLiZra2siIiJmHh5oCWhmJhwFBwcHBwcHMDAwazAwMDAwMCZmCWkeHmgHBwdlBwcHJiYmJi4uLi5rImpqCQkJCWgHBwcHBwcHJiYmJi4uLi5rImpqCQlpaWUFBAVmaGgQaAxpHh4eImtmaGhoaAwmJiIiIhcmJiYmCQkJaSImJiYmJiYmJiYmJiYmJiZ5JiIMCQkJaSImJiYmJiYmJiZ6eXkwJiYiDGgJDB4ienp6MHouejB6enoiImtrJiYmJiYmaB4iIiImJiYMaB4eIiIMaAYeJnpHR3p6aB5oCQkJaAkNDAwMaAkMHiZFenpFenp6aAwNDAwMDAwMDAwMDQ1sekd6ekVFQkJCDAxoaGgMaGgeDA0NDR4mJiZ6ekJubGwmDA0mbCIiIh58fEUmHiIMDAweHh4MDAwMeiZ6enp6QkdHeiYeDQwMDQwMDAwNHh4eenp6R0dHRUc9HgwMDAweHgwNDQwMDB4eenpHR0dHenoMDAweDB4MDA0NDQwMDA0MR0dHR0dFJh4eDQwMDAxsbh4eHgxCPWxsJGwBUlJSUlJSUlI3dGAbGxxgFxsXFxY3ORRtUlJSUlJSUnZgK2BgYBobGxcXZhw5chRtUlJSUoA3b28bGxtgYGdnF2YWB1A5bxQUUjNQUnYzYBp0YBwaHGBgHBtQHBYQEChtdDNPUlBST3JSUDNvUlJ1dlAbaGcWZhQUdFJSUlJSUlJSUnV2UFBQUDkWGxYWZhZtUlJ2UlJSUlJSdnZ2djlQUBoWaGYWZhcUUlJSUlJSUlJ2dVJ2UFB2ZhZmZhZmFhQUUlJSdlJ2dnZ1dnZQdnYvGmdoZmZmZmYXUnZSdlJ1dnV2dVBQUDkWHGYWaGdmZhYUUlJ2dnZ2dnZ1dlBQORccZmdoHBYWZhZtdnV1dnZSUlBQUFBQFhZnZxZoaBZmFmYQdXZ2dnZ2dXY5UFBvFhwWZmZoFhYWFmt5dXZ2dnZQUFBQdhoWZ2ZnFmZoaGYWZXJgdnZ1dVBQOVB2cxccFhxmaBZoZhZmcnJ5UnVQUHVQOTk5FhZnZmZmFmZoFmZycnJydlBQUFA5OXYcZ2dnZhZmaGhoZhY3cnJyUFA5UDlQUBoWHGZnZ2ZmZmhoa3JycnJyUDk5OVBQNxYcFhxnZhZmaGZlOXJycnJyOTlQUFA5FmZmHGcWZmdmZmZrcnJycnJykFgBR3xFJiYibh4MHiZ6fHxFRUVHenomMDAweEhIfHxLfHoeImxsJiYNDQ0eIiIMDAwMeEhIfHxLfHoeDGgMDQ0MDAwMDAwMDAwNSEh8fEUmImgeDQ0NDQwMDA0NDQwNHg0NfEtFJh4MDB4eHg0NDAwMDAwMDAwNaB5sfEseDA0MDB4NDQwNDAwMDAwMDA0MIkVLemwiIh4eDQ0mbCIeHgxFMGwiIh4ebmxsJiJ8SEdHfDBLR0tLR0dLS0tLS0UeDGgMS0t4eHhLS0t8TUtMS0tHTU18Ih4MHh4eeHhISEhIfHxLS0xNR01LRyYNDAweHh4eeHhIfHx8fHxLS0tLTUsmHgwNHh4eHh4eSEh8fHx8SEtLTU1LS00MDR4eHh4NDR4eSEhLS0tLS0tLS0tHJh4NDQwMDQ0eHgwNfEsiMDBFR0dubCYeDQ0NDGwiIh4NDA0NIm4iDQ0eIm5HJk1HRT1sbCIiR0I9JiIeDQ0NDR5oRUdNTUdFPUtLS0dHQj1NTU1NHh4NDSJFR01NS0tLS0tLS0tNTU1NTU1LHmhFS0tNTUtLTU1LS01LS01NTU1NTUtLaEVLS0tLR01NTUtLS0tNTU1NTU1NQiIMS0tLS0tLTUtNS0tLTU1NTU1NTU1CHh4ewE4BaWlpaWlpCWlpDB0dHR0dCX1XV1dXV1dXaWlpaWlpaWlpDB0dHR0dHR1xcXE7Ozt+aWlpaWlpaWlpDB0dHR0dHR0dCQkJCQkJaQkJCQkJCWlpaR0dHR0dHR0dHR0dHR0dPT1sbGxxHh4eCR0dHR1pHh4JCR5pHR0dPj4+Pj4+Pj4+Pj49PT07fzs7OnE7Hn0ePj4+Pj4+Pj4+cHBaW1t+flpbW1tbW1taPj4+Pj4+PnBaW1tbW35+WoJbgoJbgoKCHX19fTt+cFlbW1tbcH5aW4JbgoKCW1tbHR1xO35+fn5+fn5bW1tbW1uCgoKCgltbHTt+fn5+fn5+fluCW1tbW4KCgltbgoJbf35+fn5+fn5+cFtbW1tbgoJbW1tbgltbWlpacFpXfn5+W1tbW4KCW1uCgltbW1tbW1tbW1tbW1t+fnBwWFtbW1uCW1tbW1tbW1tbW1tbW1dXfn5+fld+fldXfldwcFhbW1tbW1tbcFd+fn5+V1d+fld+V1d+V1dXWltbgltwfn5+fn5XV35XV35+V35XV1dXfn5+flpbcHB+fllXV1dXfn5+fn5XfldXfn5+cFtbW1tbW4JbgltbW1tYfnB+V1d+fn5+W1tbW1tbgltbW1tbW1tbW1tbW1tahEQBAQkJCQFqAwQEBAQEBQUEBGoHCQQHagEEagkJampqAwEJCQlqAwUDCQkeCQEHamoBCQkJampqAwEJDAllAQZqCQkJagQEamoBCR0dCQFqBQMdHR0JAQZqCQkJCWoEamoDDHFxHWppBQMdcXEJampqCXFxHQQHCWoDHnF9HWppAwEdHR0JagFqHTo6cQYHCQkJCQkJCWpqAwEJCQlqagMJHX19HQcHCQkJagkJCWpqA2oJCQlpCQZqHR0dCWoECQkJCQkJCQkJBQYJCQlpCQZqCQkJCQkHCQkdHR0dCR0JBQYJHQlpCQZqCQkJCWkHagkJcR4eHh0JCQkJCQlpCWlqCR1xcX1pCQkdPT09PT0mbGxsbGweCQlxf38+Pj09O39/ImxsJiYmJiZsbB4JCR4eHR0dHR0eHnFxDAxpDA0ibGxuHh4eHgwMDAweHh4eCR19DAxpDA0ibGxuHh4eHgwMDAweHh4eCR19aCIiJiZ6enpFRXp6JiYmbCIiHh4ebGw9IiImJiYmRUVFRUVFRUUmbG4eHh4eHgwMIiImJiYmRUVFRUVFRUUmbG4eHh4eHgwMDAwMDAwMHh4eHiImJiIeIh4NDAweDAwMDAwMDA0MCQweIiYmfEVFRXp6JiYwMCImqGwBTU1NTU1NTU1NTU1NS0tLTU1NQ01sHh4eTU1NTU1NTU1NTU1NTU1NcHBDTT0eHh4eTU1NTU1NTU1NTU1NcHBwQ0NNcB4eHh4eTU1NTU1NTU1NTU1NQ0NDQ0NNfR4eHn0eTU1NTU1NTU1NQkJCQ0NDTU1sHh4eHh4eTU1NTU1NQkJCQ0NDTU1NQkIiHh4eHh4NTU1NTUJCQ0NDTU1NQkJCQ0NDPj0mfSIeTU1NQkNDTU1NPT09Q0NDTU1DS01NTUNwQkJCTU1NPT09Hh4eTU1NQ0NDQ0NDQ0NDTU1NJj09Hh4eQkJCQ0NDQ0NNQkJDQ3BDJiYmDB4eQkJCTU1NQ0NDS0tNQkNDcENDDAwMHkJCTU1NTU1NS0tLS0s+S01wQ0NDHh4ebE1NTU1NQ0NDS0tLR0dHS0M+Qz4+bGxsTU1NQ0NDS0tLR0dHR0dNQ0M+Q0NDTU1NTUNDS0tLTU1NR0dHS0tNR0dDQ0NDTU1NQ0tLTU1NR0dHTUtLTU1HR0dDQ0NDQ0NDS0tNR0dHTU1NTU1NR0dHRz5DQ0NDS0tLS0tLTU1NTU1HR0dHR0dHR0tDQj4+S0tNTU1HR0dHR0dHR0dHR0JHTUNCPj4+TU1HR0dHR0dHR0dHR0dHR01NTUM+PkND5FgCaQwJCWloIkNNTU1NCQkJaWloZk1NQ01NPT1sbCJoaCZNTU1NPT0mbCZlEGZNTU1NPT0mbCZpZQ0+TU1NCQkMHiIeB2VsTU1NDAxoCQkJBxBmTU1NDAxoCQkJB2VoPUNNIh4MDAwJBgdlZkNNPT09PT0mImUQZkNNkE4CIh4eDA0MaB4iJiJpDAwMDAwMaAkeJmswRUVFRXlrDR4eIiImRUV6LiIMDAwJCQloHh4mIg0MaGgJCWgJJkV6enpFRUVFenkiJiZFRUV8RXxFeiJoDQwMCQwNDR56Ih4MDQ0MDQ0NDXp6ekd6HgwMDAxoenpHR0dHqFgCHh4eHh4eHh4eHh5EHh4eHh4eHh4eHnBwbnBCPU1DPVpafX1wTU1NcHBwcH8eO35+TU1wcHBEfX9/fzt+cHBwfX19O39/f39/cEN9Oz09XHBaWlpaHn49XE1NcHBwcFpaXE1NTU1NcHBwcHBcTU1NcHBwRHBwcE1NzGwCcH47fX19fX19fX19cFpaWlpaTX47fR4ecHBwTXBNcHBwcFpNcHBwcHBNcHBwcHBNcHBNcE1NTXBwcHBNcENwcE1wTXBwQ3BNcHBwTU1wcHBwQ3BNcE1wcE1NcHBwcHBwHh4eOz5DcHBwcHBwHn0eHh4eHh19PT5wtE4CaWhpBwcHaWlpaWlpCWkMCR4eHh0JHh5pDGgJCQwJDAl/fz4+Qj1CQj4+PR07Oz09PT49PnA+Hh0eHR4dHh4eHn1wcD49f306Hh4eO3BwcHBwWltbcHA9Hn09PlpbW1tbcDseHh47fn5+f39+Pn99fX5+fn5+fn5+kBICEA4OEBAQEA4QEBAQEBBmFhoaG2trLmtray8vLmtrLmtra2tra2sbLi8ua2tra2tragFoGmtra2sua2tramoBBmhra2tra2tragZqamhraxdmZhBoeGdqagQEBAQEBAQEd3dMagQFBAQEBAQEd0x3BwUEBAQEBAQE")
    gridPatches = {}
    local offset = 1
    while offset <= #pixels do
        local px, py, scale = string.byte(pixels, offset, offset+2)
        local width, height = 24/scale, 20/scale
        local rows = {}
        for start = offset+3, offset+2+width*height, width do
            rows[#rows+1] = {string.byte(pixels, start, start+width-1)}
        end
        gridPatches[#gridPatches+1] = {x = px*2, y = py*2, scale = scale, rows = rows}
        offset = offset+3+width*height
    end
end
local Palette = {0x0000,0x0001,0x0421,0x0002,0x0022,0x0023,0x0422,0x0423,0x0443,0x0821,0x0C22,0x0843,0x0C42,0x0C43,0x0024,0x0044,0x0444,0x0445,0x0446,0x0447,0x0467,0x0C64,0x0865,0x0866,0x0C66,0x0C85,0x0886,0x0887,0x0C86,0x1021,0x1042,0x1063,0x1C41,0x1862,0x1064,0x1483,0x10A7,0x1C84,0x18A6,0x0469,0x0868,0x08A8,0x088A,0x088B,0x0CC9,0x08AE,0x10C8,0x10C9,0x18C9,0x10EA,0x18E9,0x10ED,0x0D0D,0x150A,0x1D0A,0x152E,0x192D,0x194F,0x2041,0x2062,0x2882,0x24A6,0x28C6,0x3482,0x38E7,0x24E8,0x28E8,0x30E8,0x3D07,0x2509,0x212B,0x290A,0x212C,0x254D,0x216E,0x2D4C,0x2D6E,0x3509,0x0D33,0x1571,0x1970,0x1992,0x19D5,0x11F8,0x0E3C,0x1A39,0x225A,0x44A1,0x4CC2,0x48E4,0x4506,0x5547,0x4928,0x6188,0x571A,0x0424,0x0888,0x0C87,0x192E,0x212D,0x7FFF,0x0442,0x0844,0x0885,0x0842,0x0822,0x0021,0x1087,0x1884,0x0468,0x1083,0x10CA,0x38E6,0x1840,0x192C,0x0D0C,0x08C9,0x1592,0x1993,0x5B1B,0x214D,0x14C9,0x20C8,0x190A,0x210B,0x1842,0x3481,0x2862,0x11F9,0x1E5A,0x6588}
local mode, previous = 1, false
local formats = {"BGR555", "RGB555", "RGB565"}
local function encode(c)
    if mode == 1 then return c end
    local r, g, b = c % 32, math.floor(c / 32) % 32, math.floor(c / 1024)
    if mode == 2 then return r * 1024 + g * 32 + b end
    return r * 2048 + (g * 2 + math.floor(g / 16)) * 32 + b
end
local x, y, facing, walking, step = 65, 143, 1, false, 0
local actorPalette = {
    2056,5136,7282,8549,10665,12653,10570,15820,
    15501,11133,21471,6328,11833,9511
}
local actorFaces = {
    {1,2,3,4,0},{5,8,7,6,1},{1,5,6,2,0},
    {4,3,7,8,1},{1,4,8,5,0},{2,6,7,3,1}
}

local function courier()
    local scale = 0.75 + (y - 145) / 180
    local angle = -facing * 0.75
    local sine, cosine = math.sin(angle), math.cos(angle)
    local stride = walking and math.sin(step / 4) * 2.5 or 0
    local faces = {}

    local function part(px, py, pz, w, h, d, lit, dark)
        local vertices = {}
        for _, corner in ipairs({
            {0,0,0},{1,0,0},{1,1,0},{0,1,0},
            {0,0,1},{1,0,1},{1,1,1},{0,1,1}
        }) do
            local ax = px + corner[1] * w
            local ay = py + corner[2] * h
            local az = pz + corner[3] * d
            local depth = az * cosine - ax * sine
            local magnification = scale * 95 / (95 + depth)
            vertices[#vertices + 1] = {
                math.max(0, math.min(479, math.floor(x + (ax * cosine + az * sine) * magnification))),
                math.floor(y - (ay + depth * 0.22) * magnification),
                depth
            }
        end
        for _, face in ipairs(actorFaces) do
            local a,b,c,e = vertices[face[1]],vertices[face[2]],vertices[face[3]],vertices[face[4]]
            local area = (b[1]-a[1])*(c[2]-a[2]) - (b[2]-a[2])*(c[1]-a[1])
            if area < 0 then
                faces[#faces + 1] = {a,b,c,e,a[3]+b[3]+c[3]+e[3],face[5]==0 and lit or dark}
            end
        end
    end

    part(-7,2,-3+stride,5,11,6,14,3)
    part(2,2,-3-stride,5,11,6,14,3)
    part(-7,0,-5+stride,5,3,8,5,2)
    part(2,0,-5-stride,5,3,8,5,2)
    part(-8,12,-4,16,12,8,12,9)
    part(-6,24,-4,12,8,8,13,9)
    part(-7,31,-5,14,4,10,12,9)
    part(-6,31,-9,12,2,5,12,9)
    part(-10,15,-6,4,7,6,13,9)
    part(6,15,-6,4,7,6,13,9)
    part(-10,16,-15,20,3,12,11,10)

    table.sort(faces,function(a,b) return a[5]>b[5] end)
    for _, face in ipairs(faces) do
        local a,b,c,d,color = face[1],face[2],face[3],face[4],face[6]
        ui.trisfill(a[1],a[2],b[1],b[2],c[1],c[2],color + 223)
        ui.trisfill(a[1],a[2],c[1],c[2],d[1],d[2],color + 223)
    end
end

local function held(button)
    local value = ui.btn(button, 0)
    return value == true or (type(value) == "number" and value > 0)
end

local function drawImage(image, minX, maxX)
    local scale = 2
    for i = 1, #image, 5 do
        local a,b,c,d,color = string.byte(image,i,i+4)
        if (c+1)*scale-1 >= minX and a*scale <= maxX then
            if (d+1)*scale-1 >= 16 then
                ui.rectfill(a*scale,math.max(16,b*scale),(c+1)*scale-1,(d+1)*scale-1,color-1)
            end
        end
    end
end

function update()
    local colorButton = held(BTN_X or 6)
    if colorButton and not previous then mode = mode % #formats + 1 end
    previous = colorButton
    local detailButton = held(BTN_Z or 7)
    if detailButton and not previousDetail then detail = not detail end
    previousDetail = detailButton
    ui.cls(0)
    local status
    for i, color in ipairs(Palette) do ui.palset(i-1, encode(color)) end
    for i, color in ipairs(actorPalette) do ui.palset(i+223, encode(color)) end
    local dx = (held(RIGHT or 2) and 1 or 0) - (held(LEFT or 4) and 1 or 0)
    local dy = (held(DOWN or 3) and 1 or 0) - (held(UP or 1) and 1 or 0)
    if dx ~= 0 then facing = dx end
    walking = dx ~= 0 or dy ~= 0
    if walking then step = step + 1 end
    -- Back aisle, right turn, then front aisle. The middle is furniture.
    local function walkable(px, py)
        return px >= 48 and px <= 392 and py >= 130 and py <= 230
            and (py <= 150 or py >= 207 or px >= 268)
    end
    local nextX, nextY = x + dx * 1.4, y + dy * 1.25
    if walkable(nextX, y) then x = nextX end
    if walkable(x, nextY) then y = nextY end
    local status = y <= 150 and "LUA / ATRAS" or "LUA / FRENTE"
    ui.palset(240, 0)
    ui.palset(241, encode(32767))
    ui.rectfill(0,0,479,15,240)
    ui.print("6.3 "..status.."  Z: "..(detail and "FINO" or "NORMAL").."  X: "..formats[mode],8,3,241)
    drawImage(detailedBackground, 0, 479)
    if detail and gridPatches then
        for _, patch in ipairs(gridPatches) do
            if not pcall(ui.grid, patch.x, patch.y, patch.scale, patch.scale, patch.rows) then
                gridPatches = nil
                break
            end
        end
    end
    courier()
    if y <= 150 then drawImage(detailedSofa, x-24, x+24) end
end
