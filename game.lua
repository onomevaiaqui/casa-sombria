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
local background = decode("AAAJUTUKAA4EWg8AEwFaFAAdAVseACIAWyMAJABaJQAnAFQoADsEAzwATwEEUABZAQZaAGMABmQAbQRfbgB3Ewt4AIsBX4wAlQBflgCfAQMeAR8BXCABIgEDIwEnAQNaAV4BBl8BYwFfjAGNARWOAZABVJEBlQEDDwITAloUAhgCWhkCGQJbGgIaAgQbAh0CAx4CJwQEPAJFBAZGAk8CDFACWQJeWgJjBF94AoECX4IChgJfhwKLAgOMAp8EAw8DEwNbFAMdBARGA08DDFADWQR4eAN8A199A34DEH8DgQNUggOLBAMPBBMEBEYESgQOSwRPBFt4BIEEAwoFEwkEFAUdBgQeBScGBCgFOwYMPAVABQxBBUIFDEMFRQVbRgVPBltQBVkGW1oFYwZfZAVtBV94BYsGA4wFnwYEPAZFBltkBmUGX2YGaAZeaQZtBgMUBx0HBB4HJwcMKAcxBwwyBzMHDDQHNgd4Nwc7B1s8B08JW1AHWQdbWgdeBxFfB2MHA2QHbQkDeAeBCQSCB4YJBIcHiwcEjAeVB1OWB5oHVJsHnwcTFAgYCAQZCB0IXR4IJwldKAgsCAwtCDEIWzIIOwhbUAhUCFtVCFYIEFcIWQgDWghjCQOHCIsIBIwIkAgEkQiSCBOTCJUIYpYInwgWFAkdCV0oCTsJW1AJWQkDhwmLCWKMCZ8JYgoKEwsPFAoYCw8ZCh0OVh4KJwtaKAo7C1s8CkUKW0YKTwsDUApZCwNaCmMLBGQKbQsGeAqfC2I8C0ULBAoMEwwPFAwVDAYWDBYMDBcMGAxaHgwnDFooDDEMWjIMMwxbNAw2DAY3DDsMBDwMTw4EUAxZDARaDGMMDGQMaAwMaQxqDBBrDG0MIHgMiwxijAyQDGKRDJIMYpMMlQwJlgyaDAObDJwMA50MnQwDngyeDASfDJ8MSAoNDg0kDw0TDQwUDRgODB4NJw1aKA0sDXgtDTENBDINOw0EUA1ZDQxaDV4NDF8NYw0cZA1tDiB4DYENYoINhg1ihw2IDROJDYsNCYwNlQ4Dlg2aDgObDZwOA50NnQ4Dng2eDQSfDZ8NRgoODg42Dw4QDjYRDhEONhIOEg4jEw4TDgweDiIOeCMOJw4GKA47DgRQDlQODFUOWQ4cWg5jDmZ4DnwOGH0OgQ5Sgg6LDgOeDp8ORgoPExA1FA8VDzYWDxYPNhcPFw9bGA8YDwYZDx0PDB4PJxAEKA8xEAQyDzsQBjwPRQ8MRg9KD15LD08PWFAPWRBmWg9eEANfD2AQA2EPYRABYg9iEAFjD2MQIGQPbQ8geA+LEAOMD5UQA5YPmhADmw+cEASdD50PA54PnxBGFBAYEDYZEBoQNhsQGxAjHBAdEAU8EEAQXkEQRRBYRhBPEGZkEGUQHGYQaBBeaRBtEAOdEJ0QFgoRExE1FBEdEzYeER4RNh8RHxFlIBEiEQQjEScRBCgRMREMMhE2EQw3ETsRHDwRTxFmUBFZERxaEVoRMVsRWxFRXBFeE1FfEWATUWERYRFRYhFjEwNkEW0TA3gRixEDjBGVEQSWEZoRFZsRmxNUnBGcEQSdEZ8TSAoSExM3HhIeEjYfEh8SZSASIhIMIxInEgwoEjETDjISOxNbPBJPEhxQElkTA1oSWhJRWxJbElFhEmESUXgSgRIEghKGElSHEosSFowSlRMVlhKaEhWcEpwSEx4TIhM2IxMnEyY8E0ATW0ETRRNeRhNPEwRaE1oTBFsTWxNoYRNhEwN4E4sTFZYTmhNUnBOcE2cKFBMVNxQUGB03GRQaKFwbFB0dIx4UIihlIxQkKGUlFCUoaCYUJxg6KBQsKDotFDEdMDIUNhUGNxQ7FQQ8FE8VBFAUWRQEWhRjFAxkFG0UXm4UdxRfeBSLGAuMFJUVA5YUmhUDmxSbFAScFJwYZ50UnRhnnhSfGEhQFVkVDFoVXhUOXxVjFV9kFXcVX5sVmxVkChYOGGsPFhMYNzIWMxgwNBY0GDA1FjYWAzcWOxYEPBZPFgxQFmMWX2QWbRZfbhZ3FgOMFpUWA5YWmhYDmxabGEY1FzUXWzYXNhcGNxc7FwY8F0UXBkYXTxcQUBdZF1xaF14XVV8XYxcDZBd3GAOMF5UYYpYXlxhimBeaGBg1GDYYMDcYOxgwPBg9GDA+GEAYaEEYQhhoQxhDGF9EGEUYBkYYTxgEUBhjGAMKGQ4dbA8ZEx1rJhkmHQQnGScdEDIZMx06NBk2HTA3GTsdMDwZQB0wQRlCGiVDGUUaaUYZRxkgSBlKGQZLGU8ZA1AZWRkDWhleGQNfGWAZC2EZYxkXZBltHSVuGXcdIHgZnxkrRhpPGiBQGmMaJ3gafBogfRqBGmmCGoYaE4caixoSjBqVGhKWGpcaEpgamhpimxqfGmdBG0IbJ0MbRRtpRhtHGyBIG0odIEsbTx1oUBtZGydaG2MbMHgbgRtpghuLGxKMG40bEo4bkBttkRuVG0SWG5cbEpgbmhtimxufG2dBHEEdaEIcQh0DQxxFHQRGHEccIFAcWRwnWhxjHDB4HIEdaYIcgh0rgxyDHRKEHIQdEoUchRxuhhyGHW+HHIsdb4wclR1vlhyXHRKYHJodYpscnB1nnRydHWeeHJ8dSEYdRx0EUB1RHSdSHVQdBlUdWR0GWh1jHQaFHYUdRAoeDihBDx4TKEAUHhgoaxseHSIjJh4mIgQnHiciEC0eLSIELh4uImYvHjEeBjIeMh4EMx4zIgQ0HjYoOjceOygwPB5PKCBQHlEiJ1IeVCJUVR5ZHxNaHl4fE18eYCJiYR5hImJiHmMfKGQebSglbh5vImhwHnIfIHMedyJpeB58Iml9Hn4faX8egSJkgh6CImSDHoMiEoQehCIShR6FIkSGHoYib4ceix9EjB6QIm+RHpIeb5MekyIplB6UIiiVHpUiEpYelyISmB6aImKbHpwiZ50enSJKnh6fIkgvHzEfZjIfMh9mkR+RH0SSH5IfbS8gMSJmMiAyImZVIFkiFlogXiATYiBjIipwIHIiaH0gfiJkhyCLIm+RIJIibVohXiIEGyMdIyMmIyYlBicjJyUQLSMtIwQuIy4jZi8jMSNmMiMyJVczIzMlBFAjUSgnUiNSKAZTI1MoU1QjVChiVSNWJWJXI1koYlojXihiXyNgKGRhI2ElZGIjYiVkYyNjJW5uI3IjJXMjdyNpeCN5JWl6I3wocn0jgSgsgiOCI0aDI4MjEoQjhCMShSOFI0SGI4Yjb4cjiyNvjCOQJUSRI5UoKJYjlygSmCOaKGKbI5woZ50jnShKniOfKEgbJB0kIS0kLSQELiQuJGYvJDEkZm4kdyVfgiSCJEaDJIMkFIQkhCQUhSSFJESGJIYkb4ckiCRviSSLJG0bJR0lDC0lMSUGgiWLJW4bJh0mNiYmJyg7LSYxJjAyJjMoOlUmVigVYSZjJmRuJnIoB3MmcyYBdCZ0Jml1JncmaXgmeSZpgiaCKEaDJoMoFIQmhCgUhSaFKESGJoYobYcmiyhtjCaQKG0bJx0oPC0nMSg6YSdjJ2RzJ3cnYngneSgrYShhKChiKGMoBHModygJCikTLXQUKRUqaxYpGDJrGSkZUTcaKRotaxspHVEkHiknKjsoKTEqOjIpOyowPClPKiBQKVEtaFIpUjIMUylTLQRUKVQtYlUpWS0LWilbKWJcKVwpBF0pXiliXyljMhNkKWQtDGUpZS0gZiloLSdpKW0tJW4pcipgcyl0LRN1KXcyYngpn1FkWipeKg4UKxQtdBUrFS1sHisnKzsoKzErOjIrOyswPCtFLRpGK0YtGkcrRy0OSCtKLSBLK08tZlorXi0KbitvLV9wK3ItBx4sIiw7IywnLDYoLDstHh4tJy0eCi4OLnQPLhAudBEuEy5BFC4VMmsaLhovNx4uIjIaIy4nMh4oLjsyHjwuTzIaUC5RLhBTLlMvU1QuVC8IVS5ZLwhaLl4vCGQuZC8GZS5lLyBmLmgvJ2kubS9obi5yMgRzLnQyAQovEy81UC9RLwYKMAswcwwwDjBdDzAQMA8RMBEwNRIwEjBxEzATMGwaMBowN1AwUTB1UzBTMmlUMFQwE1UwWTAUWjBeMAlkMG0wIgoxEzIkGjEaMTxQMVEyXVQxVDFpVTFZMRhaMVoxaVsxWzETXDFeMRRkMW0yBhoyGjIMVDJUMjFVMlYyMVcyVzILWDJZMhhaMlsyMVwyXDIxXTJeMhMKMwo0cwszCzNADDMONA0PMxA8GhEzETQNEjMTNEEUMxU0QBYzGDRrGjMaPA0eMx8zdSAzIjR1IzMnMx4oMzs0HjwzRTceRjNKNB5LM08zY1AzUTNdUjNSM11TM1MzIFQzVDMxVTNWMzFXM1czMFgzWDNpWTNZMwlaM2M0aWQzaDMVaTNtMwhuM3c0Aws0CzQkHjQfNF0jNCQ0dSU0JTR1JjQnNB5LNE80G1A0VDQOVTRZNBVkNG00FQo1CzceDDUONQ0RNRE3GhI1EzceFDUVNR8WNRY1dRc1GDU4HjUiN10jNSQ3YyU1JTdjJjUmNxsnNSc1Hig1LDUPLTUxNR8yNTs1dUY1RzV1SDVKNR5LNU83Y1A1UTddUjVSNw9TNVQ1E1U1VTUIVjVWNwlXNVk3LVo1XjUJXzVgNQhhNWE1aWI1YzUxZDVtN2luNW81aXA1cjUJczV3NSsMNg42GhQ2FDZ1FTYVNhsWNhg3Bic2Jzd1KDY7N3VGNko3Y1M2UzYwVDZUNmpVNlU2MFo2WjZqWzZbNjFcNl43MV82YzcJbjZuNjFvNm82aXA2cjYTczZ0Ngh1NnU2YnY2dzZ2DDcON3UUNxU3BlM3UzcgVDdUNwhVN1U3E1o3WzcIbjdyNzJzN3M3dnQ3dDcSdTd3NxIKOAs5BAw4DjwEETgROAwSOBM4DBQ4FTgEFjgWPAMXOBc8Bhg4GDxdHjgiPF0jOCQ5YyU4JTljJjgmORonOCc4dSg4LDh1LTguOHUvODE4GzI4OzkaPDhPPA9QOFE8XVI4UjxdUzhTOTBUOFQ5alU4VTwxVjhWOGpXOFc4alg4WTgVWjheOGpfOGA4amE4YTgzYjhjOQhkOG08K244bzgJcDhyPCtzOHM4SXQ4dDh2dTh3OBYRORE5WhI5EzlAFDkVOUAnOSc5Hig5MTkaVjlWOQlXOVk5CVo5XjkJXzlgORhhOWE5E245bjl2bzlvOWJzOXc5SAo6CzxbEToRPB8SOhM8bBQ6FTxsIzonPGMoOjE6GjI6NjoZNzo7OgxTOlQ6CVY6VjpqVzpXPDFYOlg6aVk6WToTWjpbOghcOlw6CV06XToYXjpeOk9fOmM6am46bjxJbzpvPHZzOnc6FCg7OzwPUztUO2pWO1Y7alg7WDtqWTtZOzFaO1o7T1s7WzsxXDtePAlfO187MWA7YDtPYTtjO09zO3Q7EnU7dTsUdjt2OxR3O3c7SlM8UzxeVDxUPCJWPFY8EFg8WTwQWjxbPBBfPGA8CWE8YTwSYjxiPAhjPGM8M3M8dDxKdTx1PHB2PHY8KHc8dzxFCj0TRg4UPRU+DxY9FkEDFz0YQQYaPRpRNR49IkFdIz0nQWMoPTs+Yzw9T1EcUD1ZPhxaPV4+EF89YD0IYT1hPjNiPWM+T2Q9ZD5PZT1lPklmPWhRaWk9aT4zaj1qQS5rPW1RK249b0YrcD1yUWJzPXQ9SnU9dz5uXz5gPhFzPnM+KHQ+dD5FFD8VP10oPzE/YzI/Nj9jNz84Pw85Pzs/VFA/WUEiWj9eQSJfP2M/EGQ/ZT8IaT9pPxJzP3Q/SnU/d0FKFEAUQAwVQBVAdShAMUBjMkA2QFQ3QDhAATlAOUALOkA7QBxfQGBBHGFAY0FcZEBlQRVpQGlBSXNAdEBKFEEVQXEoQSxBDy1BMUEDMkE7QRxzQXRBKBRCFUMDFkIWQwMXQhdDBRhCGEN4HkInQwwoQixCBC1CLkJbL0IxQiQyQjNCJDRCNkIdN0I7QhBQQmNGImRCZUYgaUJqRhhzQndDFChDLEMkLUMuQyMvQzFDeDJDNkN4N0M7QyEURBhEEB5EJ0YfKEQxRBoyRDtEIXNEd0QUFEUVRVYWRRhGcShFO0Yjc0V0Rkl1RXVFSnZFdkUvd0V3RSgURhVGQnVGdUZJdkZ3RkoKRxNRWBRHFUdCFkcYSHEeRx9HQSBHIktdI0ckS2MlRyVLYyZHJ0gjKEcsSyQtRzFLIzJHNksjN0c7S2ZQR1lIIlpHXkhmX0dgSxFhR2FLIGJHY1EtZEdlSF9pR2pIFW5Hb0hJc0d0SEl1R3VISHZHdkdId0d3SBIUSBRIEBVIFUhxHkgfSAV2SHZIZBRJFEsOFUkVSV4WSRZJXhdJF0lbGEkYS0MeSR9LXiZJJktjJ0knS1hQSVlJIlpJXksQZEllSRFpSWpLEm5Jb0sSc0lzSXZ0SXRJSXVJdUlJdkl3SRQVShVKXhZKFkpeF0oXSlpQSlRKIlVKWUsQZEplSjNzSnRKEnVKdUtJdkp3S0gVSxVLQBZLFktAF0sXS0BQS1RLEGRLZEtJZUtlSwhzS3NLEnRLdEtIFEwVTj4WTBhOPh5MHk48H0wfTDwgTCBMXiFMIk4QI0wjTiEkTCROXSVMJ05jKEw7TmZQTFFOF1JMVE4QVUxZTBBaTF5OCV9MYE4JYUxhTglkTGVRM2lMakwSbkxvTBJzTHNME3RMdExJdUx3TEgfTR9NPCBNIE0+VU1ZTglpTWpOM25Nb00Sc010Tkl1TXVOSXZNd05IH04fTgQgTiBOXm5Obk5Jb05vTnYUTxVPPBZPGE88Hk8fUQsgTyJRCyNPJFELJU8lUQsmTydRDyhPO1EcUE9UT2pVT1VPalZPVk9pV09ZTwlaT15PCV9PYE8JYU9hUTNpT2pRM25Pb09Jc090Twl1T3dPSBRQFVA8FlAYUDxQUFlRalpQWlAxW1BbUBNcUF5QCV9QX1AJYFBgUTNuUG9RM3NQd1ESFFEVUQUWURZRNxdRF1E2GFEYUQRaUV5RM19RX1Ex")
local sofa = decode("OCs7KzA8K0YrGkcrRysOJiwnLDYoLDssHjwsRiwaRyxHLA5ILEgsICAtOy0ePC1GLRpHLUctDkgtSS0gHi4iLhojLjsuHjwuSy4aHi8iLxojLzsvHjwvTy8aHjAiMBojMDswHjwwTzAaUDBRMHVSMFIwDBsxHTEkHjEiMRojMTsxHjwxTzEaUDFRMV1SMVIxDBoyGjIMGzIdMiQeMiIyGiMyOzIePDJPMhpQMlEyXVIyUjIMGjMaMw0bMx0zJB4zIjN1IzNKMx5LM08zY1AzUjNdGjQaNA0bNB00JB40HzRdIDQlNHUmNEo0Hks0TzQbUDRTNA4aNRo1DRs1HTUkHjUiNV0jNSU1YyY1JjUbJzUnNR4oNSw1Dy01MTUfMjU7NXU8NUU1HkY1RzV1SDVKNR5LNU81Y1A1UTVdUjVSNQ9TNVM1Exo2GjYNGzYdNiQeNiI2XSM2JTZjJjYmNhsnNjs2dTw2RTYeRjZPNmNQNlE2XVI2UjYPUzZTNjAaNxo3DRs3HTckHjciN10jNyU3YyY3JjcbJzc7N3U8N0U3HkY3TzdjUDdRN11SN1I3D1M3UzcgGjgaOA0bOB04JB44IjhdIzglOGMmOCY4Gic4Ljh1LzgxOBsyODs4Gjw4TzgPUDhSOF1TOFM4MBo5GjkNGzkdOSQeOSI5XSM5JTljJjkmORonOSc5Hig5OzkaPDlPOQ9QOVI5XVM5UzkwGjoaOg0bOh06JB46IjpdIzonOmMoOjE6GjI6NjoZNzo7Ogw8Ok86D1A6UjpdUzpTOgkaOxo7DRs7HTskHjsiO10jOyc7Yyg7TzsPUDtSO10aPBo8DRs8HTwkHjwiPF0jPCc8Yyg8TzwPUDxQPF0aPRo9NRs9HT0kHj0iPV0jPTs9Yzw9Tj0cGj4aPjUbPh0+JB4+Ij5dIz47PmM8Pkg+HBo/Gj81Gz8dPyQePyI/XSM/Nj9jNz84Pw85Pzs/VDw/QT8cGkAaQDUbQB1AJB5AIkBdI0AxQGMyQDZAVDdAOEABOUA5QAs6QDpAHBxBHUEkHkEiQV0jQSdBYyhBLEEPLUExQQMyQTNBHB5CJ0IMKEIsQgQtQi1CWyBDJkMM")
local Palette ={0x0000,0x0400,0x0001,0x0002,0x0423,0x0023,0x0441,0x0800,0x0C21,0x0822,0x0843,0x0024,0x0025,0x0445,0x0047,0x0866,0x0C87,0x1020,0x1442,0x1820,0x1465,0x1883,0x1087,0x1886,0x0448,0x046A,0x046C,0x0CA9,0x0CAA,0x088D,0x08AD,0x14C9,0x10EB,0x10EA,0x10EC,0x0D0D,0x1D0B,0x152D,0x1D0C,0x2440,0x2C40,0x3062,0x24A5,0x34C6,0x24E9,0x30E8,0x3D07,0x254D,0x2D4C,0x392A,0x394D,0x0CD3,0x1573,0x1972,0x1995,0x19D6,0x19F8,0x2570,0x2592,0x21D5,0x35B0,0x21F8,0x0A5F,0x1A1A,0x1A5D,0x1EBE,0x223A,0x4880,0x48A3,0x40E8,0x5527,0x4929,0x496D,0x5929,0x68E1,0x6D44,0x6569,0x79A8,0x41D1,0x7E0A,0x6F9D,0x0401,0x0402,0x0422,0x0424,0x0867,0x0C88,0x0CCA,0x7FFF,0x08AA,0x08A9,0x0887,0x0046,0x0444,0x1086,0x0440,0x0000,0x2485,0x0048,0x34A6,0x150D,0x10CA,0x5507,0x190B,0x24C9,0x3590,0x19D7,0x19F9,0x2840,0x2C61,0x68E0,0x6969,0x1A7D,0x30C8,0x1ABF,0x067F,0x08D3,0x390A,0x7144,0x0888}

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
    for i = 1, #image, 5 do
        local a,b,c,d,color = string.byte(image,i,i+4)
        if c*3+2 >= minX and a*3 <= maxX then
            if d*3+2 >= 16 then ui.rectfill(a*3,math.max(16,b*3),c*3+2,d*3+2,color-1) end
        end
    end
end

function update()
    local colorButton = held(BTN_X or 6)
    if colorButton and not previous then mode = mode % #formats + 1 end
    previous = colorButton
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
    ui.print("3.4 "..status.."   X: "..formats[mode],8,3,241)
    drawImage(background, 0, 479)
    courier()
    if y <= 150 then drawImage(sofa, x-24, x+24) end
end