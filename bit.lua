local bit = bit32 or bit

if not bit then
    local floor = math.floor
    local to32 = function(x) return x % 2^32 end

    local function lshift(x, n)
        return to32((x % 2^32) * 2^n)
    end

    local function rshift(x, n)
        return floor((x % 2^32) / 2^n)
    end

    local function arshift(x, n)
        x = x % 2^32
        if x >= 0x80000000 then
            return floor((x - 0x100000000) / 2^n)
        else
            return floor(x / 2^n)
        end
    end

    local function band(a, b)
        local r, bitval = 0, 1
        a, b = a % 2^32, b % 2^32

        for _ = 0, 31 do
            if (a % 2 == 1) and (b % 2 == 1) then
                r = r + bitval
            end
            a = floor(a / 2)
            b = floor(b / 2)
            bitval = bitval * 2
        end
        return r
    end

    local function bor(a, b)
        local r, bitval = 0, 1
        a, b = a % 2^32, b % 2^32

        for _ = 0, 31 do
            if (a % 2 == 1) or (b % 2 == 1) then
                r = r + bitval
            end
            a = floor(a / 2)
            b = floor(b / 2)
            bitval = bitval * 2
        end
        return r
    end

    local function bxor(a, b)
        local r, bitval = 0, 1
        a, b = a % 2^32, b % 2^32

        for _ = 0, 31 do
            if (a % 2) ~= (b % 2) then
                r = r + bitval
            end
            a = floor(a / 2)
            b = floor(b / 2)
            bitval = bitval * 2
        end
        return r
    end

    local function bnot(x)
        return to32(0xFFFFFFFF - (x % 2^32))
    end

    local function rol(x, n)
        x = x % 2^32
        n = n % 32
        return to32(lshift(x, n) + rshift(x, 32 - n))
    end

    local function ror(x, n)
        x = x % 2^32
        n = n % 32
        return to32(rshift(x, n) + lshift(x, 32 - n))
    end

    local function extract(x, field, width)
        width = width or 1
        return rshift(x, field) % 2^width
    end

    local function replace(x, v, field, width)
        width = width or 1
        local mask = lshift(2^width - 1, field)
        return bor(band(x, bnot(mask)), lshift(v, field))
    end

    bit = {
        band = band,
        bor = bor,
        bxor = bxor,
        bnot = bnot,
        lshift = lshift,
        rshift = rshift,
        arshift = arshift,
        rol = rol,
        ror = ror,
        extract = extract,
        replace = replace
    }
end

return bit
