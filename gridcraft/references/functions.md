# GridCraft worksheet functions

514 functions in 14 categories, GridCraft 0.9.0. Generated from `gridcraft-cli functions --json` on 2026-10-22.

Signatures use square brackets for optional arguments. Use `list_functions({search,category})` over MCP or `gridcraft-cli functions` for descriptions.

| Category | Count |
|---|---|
| AddIn | 1 |
| Compatibility | 42 |
| Cube | 7 |
| Database | 12 |
| DateTime | 25 |
| Engineering | 54 |
| Financial | 55 |
| Information | 22 |
| Logical | 19 |
| Lookup | 36 |
| MathTrig | 80 |
| Statistical | 110 |
| Text | 48 |
| Web | 3 |

## AddIn

- `EUROCONVERT` — `EUROCONVERT(number, source, target, [full_precision], [triangulation_precision])`

## Compatibility

- `BETADIST` — `BETADIST(x, alpha, beta, [A], [B])`
- `BETAINV` — `BETAINV(probability, alpha, beta, [A], [B])`
- `BINOMDIST` — `BINOMDIST(number_s, trials, probability_s, cumulative)`
- `CEILING` — `CEILING(number, significance)`
- `CHIDIST` — `CHIDIST(x, deg_freedom)`
- `CHIINV` — `CHIINV(probability, deg_freedom)`
- `CHITEST` — `CHITEST(actual_range, expected_range)`
- `CONFIDENCE` — `CONFIDENCE(alpha, standard_dev, size)`
- `COVAR` — `COVAR(array1, array2)`
- `CRITBINOM` — `CRITBINOM(trials, probability_s, alpha)`
- `EXPONDIST` — `EXPONDIST(x, lambda, cumulative)`
- `FDIST` — `FDIST(x, deg_freedom1, deg_freedom2)`
- `FINV` — `FINV(probability, deg_freedom1, deg_freedom2)`
- `FLOOR` — `FLOOR(number, significance)`
- `FORECAST` — `FORECAST(x, known_ys, known_xs)`
- `FTEST` — `FTEST(array1, array2)`
- `GAMMADIST` — `GAMMADIST(x, alpha, beta, cumulative)`
- `GAMMAINV` — `GAMMAINV(probability, alpha, beta)`
- `HYPGEOMDIST` — `HYPGEOMDIST(sample_s, number_sample, population_s, number_pop)`
- `LOGINV` — `LOGINV(probability, mean, standard_dev)`
- `LOGNORMDIST` — `LOGNORMDIST(x, mean, standard_dev)`
- `MODE` — `MODE(number1, [number2], ...)`
- `NEGBINOMDIST` — `NEGBINOMDIST(number_f, number_s, probability_s)`
- `NORMDIST` — `NORMDIST(x, mean, standard_dev, cumulative)`
- `NORMINV` — `NORMINV(probability, mean, standard_dev)`
- `NORMSDIST` — `NORMSDIST(z)`
- `NORMSINV` — `NORMSINV(probability)`
- `PERCENTILE` — `PERCENTILE(array, k)`
- `PERCENTRANK` — `PERCENTRANK(array, x, [significance])`
- `POISSON` — `POISSON(x, mean, cumulative)`
- `QUARTILE` — `QUARTILE(array, quart)`
- `RANK` — `RANK(number, ref, [order])`
- `STDEV` — `STDEV(number1, [number2], ...)`
- `STDEVP` — `STDEVP(number1, [number2], ...)`
- `TDIST` — `TDIST(x, deg_freedom, tails)`
- `TINV` — `TINV(probability, deg_freedom)`
- `TTEST` — `TTEST(array1, array2, tails, type)`
- `USDOLLAR` — `USDOLLAR(number, [decimals])`
- `VAR` — `VAR(number1, [number2], ...)`
- `VARP` — `VARP(number1, [number2], ...)`
- `WEIBULL` — `WEIBULL(x, alpha, beta, cumulative)`
- `ZTEST` — `ZTEST(array, x, [sigma])`

## Cube

- `CUBEKPIMEMBER` — `CUBEKPIMEMBER(connection, kpi_name, kpi_property, [caption])`
- `CUBEMEMBER` — `CUBEMEMBER(connection, member_expression, [caption])`
- `CUBEMEMBERPROPERTY` — `CUBEMEMBERPROPERTY(connection, member_expression, property)`
- `CUBERANKEDMEMBER` — `CUBERANKEDMEMBER(connection, set_expression, rank, [caption])`
- `CUBESET` — `CUBESET(connection, set_expression, [caption], [sort_order], [sort_by])`
- `CUBESETCOUNT` — `CUBESETCOUNT(set)`
- `CUBEVALUE` — `CUBEVALUE(connection, [member_expression1], ...)`

## Database

- `DAVERAGE` — `DAVERAGE(database, field, criteria)`
- `DCOUNT` — `DCOUNT(database, [field], criteria)`
- `DCOUNTA` — `DCOUNTA(database, [field], criteria)`
- `DGET` — `DGET(database, field, criteria)`
- `DMAX` — `DMAX(database, field, criteria)`
- `DMIN` — `DMIN(database, field, criteria)`
- `DPRODUCT` — `DPRODUCT(database, field, criteria)`
- `DSTDEV` — `DSTDEV(database, field, criteria)`
- `DSTDEVP` — `DSTDEVP(database, field, criteria)`
- `DSUM` — `DSUM(database, field, criteria)`
- `DVAR` — `DVAR(database, field, criteria)`
- `DVARP` — `DVARP(database, field, criteria)`

## DateTime

- `DATE` — `DATE(year, month, day)`
- `DATEDIF` — `DATEDIF(start_date, end_date, unit)`
- `DATEVALUE` — `DATEVALUE(date_text)`
- `DAY` — `DAY(serial_number)`
- `DAYS` — `DAYS(end_date, start_date)`
- `DAYS360` — `DAYS360(start_date, end_date, [method])`
- `EDATE` — `EDATE(start_date, months)`
- `EOMONTH` — `EOMONTH(start_date, months)`
- `HOUR` — `HOUR(serial_number)`
- `ISOWEEKNUM` — `ISOWEEKNUM(date)`
- `MINUTE` — `MINUTE(serial_number)`
- `MONTH` — `MONTH(serial_number)`
- `NETWORKDAYS` — `NETWORKDAYS(start_date, end_date, [holidays])`
- `NETWORKDAYS.INTL` — `NETWORKDAYS.INTL(start_date, end_date, [weekend], [holidays])`
- `NOW` — `NOW()`
- `SECOND` — `SECOND(serial_number)`
- `TIME` — `TIME(hour, minute, second)`
- `TIMEVALUE` — `TIMEVALUE(time_text)`
- `TODAY` — `TODAY()`
- `WEEKDAY` — `WEEKDAY(serial_number, [return_type])`
- `WEEKNUM` — `WEEKNUM(serial_number, [return_type])`
- `WORKDAY` — `WORKDAY(start_date, days, [holidays])`
- `WORKDAY.INTL` — `WORKDAY.INTL(start_date, days, [weekend], [holidays])`
- `YEAR` — `YEAR(serial_number)`
- `YEARFRAC` — `YEARFRAC(start_date, end_date, [basis])`

## Engineering

- `BESSELI` — `BESSELI(x, n)`
- `BESSELJ` — `BESSELJ(x, n)`
- `BESSELK` — `BESSELK(x, n)`
- `BESSELY` — `BESSELY(x, n)`
- `BIN2DEC` — `BIN2DEC(number)`
- `BIN2HEX` — `BIN2HEX(number, [places])`
- `BIN2OCT` — `BIN2OCT(number, [places])`
- `BITAND` — `BITAND(number1, number2)`
- `BITLSHIFT` — `BITLSHIFT(number, shift_amount)`
- `BITOR` — `BITOR(number1, number2)`
- `BITRSHIFT` — `BITRSHIFT(number, shift_amount)`
- `BITXOR` — `BITXOR(number1, number2)`
- `COMPLEX` — `COMPLEX(real_num, i_num, [suffix])`
- `CONVERT` — `CONVERT(number, from_unit, to_unit)`
- `DEC2BIN` — `DEC2BIN(number, [places])`
- `DEC2HEX` — `DEC2HEX(number, [places])`
- `DEC2OCT` — `DEC2OCT(number, [places])`
- `DELTA` — `DELTA(number1, [number2])`
- `ERF` — `ERF(lower_limit, [upper_limit])`
- `ERF.PRECISE` — `ERF.PRECISE(x)`
- `ERFC` — `ERFC(x)`
- `ERFC.PRECISE` — `ERFC.PRECISE(x)`
- `GESTEP` — `GESTEP(number, [step])`
- `HEX2BIN` — `HEX2BIN(number, [places])`
- `HEX2DEC` — `HEX2DEC(number)`
- `HEX2OCT` — `HEX2OCT(number, [places])`
- `IMABS` — `IMABS(inumber)`
- `IMAGINARY` — `IMAGINARY(inumber)`
- `IMARGUMENT` — `IMARGUMENT(inumber)`
- `IMCONJUGATE` — `IMCONJUGATE(inumber)`
- `IMCOS` — `IMCOS(inumber)`
- `IMCOSH` — `IMCOSH(inumber)`
- `IMCOT` — `IMCOT(inumber)`
- `IMCSC` — `IMCSC(inumber)`
- `IMCSCH` — `IMCSCH(inumber)`
- `IMDIV` — `IMDIV(inumber1, inumber2)`
- `IMEXP` — `IMEXP(inumber)`
- `IMLN` — `IMLN(inumber)`
- `IMLOG10` — `IMLOG10(inumber)`
- `IMLOG2` — `IMLOG2(inumber)`
- `IMPOWER` — `IMPOWER(inumber, number)`
- `IMPRODUCT` — `IMPRODUCT(inumber1, [inumber2], ...)`
- `IMREAL` — `IMREAL(inumber)`
- `IMSEC` — `IMSEC(inumber)`
- `IMSECH` — `IMSECH(inumber)`
- `IMSIN` — `IMSIN(inumber)`
- `IMSINH` — `IMSINH(inumber)`
- `IMSQRT` — `IMSQRT(inumber)`
- `IMSUB` — `IMSUB(inumber1, inumber2)`
- `IMSUM` — `IMSUM(inumber1, [inumber2], ...)`
- `IMTAN` — `IMTAN(inumber)`
- `OCT2BIN` — `OCT2BIN(number, [places])`
- `OCT2DEC` — `OCT2DEC(number)`
- `OCT2HEX` — `OCT2HEX(number, [places])`

## Financial

- `ACCRINT` — `ACCRINT(issue, first_interest, settlement, rate, par, frequency, [basis], [calc_method])`
- `ACCRINTM` — `ACCRINTM(issue, settlement, rate, [par], [basis])`
- `AMORDEGRC` — `AMORDEGRC(cost, date_purchased, first_period, salvage, period, rate, [basis])`
- `AMORLINC` — `AMORLINC(cost, date_purchased, first_period, salvage, period, rate, [basis])`
- `COUPDAYBS` — `COUPDAYBS(settlement, maturity, frequency, [basis])`
- `COUPDAYS` — `COUPDAYS(settlement, maturity, frequency, [basis])`
- `COUPDAYSNC` — `COUPDAYSNC(settlement, maturity, frequency, [basis])`
- `COUPNCD` — `COUPNCD(settlement, maturity, frequency, [basis])`
- `COUPNUM` — `COUPNUM(settlement, maturity, frequency, [basis])`
- `COUPPCD` — `COUPPCD(settlement, maturity, frequency, [basis])`
- `CUMIPMT` — `CUMIPMT(rate, nper, pv, start_period, end_period, type)`
- `CUMPRINC` — `CUMPRINC(rate, nper, pv, start_period, end_period, type)`
- `DB` — `DB(cost, salvage, life, period, [month])`
- `DDB` — `DDB(cost, salvage, life, period, [factor])`
- `DISC` — `DISC(settlement, maturity, pr, redemption, [basis])`
- `DOLLARDE` — `DOLLARDE(fractional_dollar, fraction)`
- `DOLLARFR` — `DOLLARFR(decimal_dollar, fraction)`
- `DURATION` — `DURATION(settlement, maturity, coupon, yld, frequency, [basis])`
- `EFFECT` — `EFFECT(nominal_rate, npery)`
- `FV` — `FV(rate, nper, pmt, [pv], [type])`
- `FVSCHEDULE` — `FVSCHEDULE(principal, schedule)`
- `INTRATE` — `INTRATE(settlement, maturity, investment, redemption, [basis])`
- `IPMT` — `IPMT(rate, per, nper, pv, [fv], [type])`
- `IRR` — `IRR(values, [guess])`
- `ISPMT` — `ISPMT(rate, per, nper, pv)`
- `MDURATION` — `MDURATION(settlement, maturity, coupon, yld, frequency, [basis])`
- `MIRR` — `MIRR(values, finance_rate, reinvest_rate)`
- `NOMINAL` — `NOMINAL(effect_rate, npery)`
- `NPER` — `NPER(rate, pmt, pv, [fv], [type])`
- `NPV` — `NPV(rate, value1, [value2], ...)`
- `ODDFPRICE` — `ODDFPRICE(settlement, maturity, issue, first_coupon, rate, yld, redemption, frequency, [basis])`
- `ODDFYIELD` — `ODDFYIELD(settlement, maturity, issue, first_coupon, rate, pr, redemption, frequency, [basis])`
- `ODDLPRICE` — `ODDLPRICE(settlement, maturity, last_interest, rate, yld, redemption, frequency, [basis])`
- `ODDLYIELD` — `ODDLYIELD(settlement, maturity, last_interest, rate, pr, redemption, frequency, [basis])`
- `PDURATION` — `PDURATION(rate, pv, fv)`
- `PMT` — `PMT(rate, nper, pv, [fv], [type])`
- `PPMT` — `PPMT(rate, per, nper, pv, [fv], [type])`
- `PRICE` — `PRICE(settlement, maturity, rate, yld, redemption, frequency, [basis])`
- `PRICEDISC` — `PRICEDISC(settlement, maturity, discount, redemption, [basis])`
- `PRICEMAT` — `PRICEMAT(settlement, maturity, issue, rate, yld, [basis])`
- `PV` — `PV(rate, nper, pmt, [fv], [type])`
- `RATE` — `RATE(nper, pmt, pv, [fv], [type], [guess])`
- `RECEIVED` — `RECEIVED(settlement, maturity, investment, discount, [basis])`
- `RRI` — `RRI(nper, pv, fv)`
- `SLN` — `SLN(cost, salvage, life)`
- `SYD` — `SYD(cost, salvage, life, per)`
- `TBILLEQ` — `TBILLEQ(settlement, maturity, discount)`
- `TBILLPRICE` — `TBILLPRICE(settlement, maturity, discount)`
- `TBILLYIELD` — `TBILLYIELD(settlement, maturity, pr)`
- `VDB` — `VDB(cost, salvage, life, start_period, end_period, [factor], [no_switch])`
- `XIRR` — `XIRR(values, dates, [guess])`
- `XNPV` — `XNPV(rate, values, dates)`
- `YIELD` — `YIELD(settlement, maturity, rate, pr, redemption, frequency, [basis])`
- `YIELDDISC` — `YIELDDISC(settlement, maturity, pr, redemption, [basis])`
- `YIELDMAT` — `YIELDMAT(settlement, maturity, issue, rate, pr, [basis])`

## Information

- `CELL` — `CELL(info_type, [reference])`
- `ERROR.TYPE` — `ERROR.TYPE(error_val)`
- `HYPERLINK` — `HYPERLINK(link_location, [friendly_name])`
- `INFO` — `INFO(type_text)`
- `ISBLANK` — `ISBLANK(value)`
- `ISERR` — `ISERR(value)`
- `ISERROR` — `ISERROR(value)`
- `ISEVEN` — `ISEVEN(number)`
- `ISFORMULA` — `ISFORMULA(reference)`
- `ISLOGICAL` — `ISLOGICAL(value)`
- `ISNA` — `ISNA(value)`
- `ISNONTEXT` — `ISNONTEXT(value)`
- `ISNUMBER` — `ISNUMBER(value)`
- `ISODD` — `ISODD(number)`
- `ISOMITTED` — `ISOMITTED(argument)`
- `ISREF` — `ISREF(value)`
- `ISTEXT` — `ISTEXT(value)`
- `N` — `N(value)`
- `NA` — `NA()`
- `SHEET` — `SHEET([value])`
- `SHEETS` — `SHEETS([reference])`
- `TYPE` — `TYPE(value)`

## Logical

- `AND` — `AND(logical1, [logical2], ...)`
- `BYCOL` — `BYCOL(array, lambda)`
- `BYROW` — `BYROW(array, lambda)`
- `FALSE` — `FALSE()`
- `IF` — `IF(logical_test, [value_if_true], [value_if_false])`
- `IFERROR` — `IFERROR(value, value_if_error)`
- `IFNA` — `IFNA(value, value_if_na)`
- `IFS` — `IFS(logical_test1, value_if_true1, ...)`
- `LAMBDA` — `LAMBDA([parameter1, ...], calculation)`
- `LET` — `LET(name1, value1, ..., calculation)`
- `MAKEARRAY` — `MAKEARRAY(rows, cols, lambda)`
- `MAP` — `MAP(array1, ..., lambda)`
- `NOT` — `NOT(logical)`
- `OR` — `OR(logical1, [logical2], ...)`
- `REDUCE` — `REDUCE(initial_value, array, lambda)`
- `SCAN` — `SCAN(initial_value, array, lambda)`
- `SWITCH` — `SWITCH(expression, value1, result1, [default_or_value2, result2], ...)`
- `TRUE` — `TRUE()`
- `XOR` — `XOR(logical1, [logical2], ...)`

## Lookup

- `ADDRESS` — `ADDRESS(row_num, column_num, [abs_num], [a1], [sheet_text])`
- `AREAS` — `AREAS(reference)`
- `CHOOSE` — `CHOOSE(index_num, value1, [value2], ...)`
- `CHOOSECOLS` — `CHOOSECOLS(array, col_num1, [col_num2], ...)`
- `CHOOSEROWS` — `CHOOSEROWS(array, row_num1, [row_num2], ...)`
- `COLUMN` — `COLUMN([reference])`
- `COLUMNS` — `COLUMNS(array)`
- `DROP` — `DROP(array, rows, [columns])`
- `EXPAND` — `EXPAND(array, rows, [columns], [pad_with])`
- `FILTER` — `FILTER(array, include, [if_empty])`
- `FORMULATEXT` — `FORMULATEXT(reference)`
- `GROUPBY` — `GROUPBY(row_fields, values, function, [field_headers], [total_depth], [sort_order], [filter_array], [field_relationship])`
- `HLOOKUP` — `HLOOKUP(lookup_value, table_array, row_index_num, [range_lookup])`
- `HSTACK` — `HSTACK(array1, [array2], ...)`
- `INDEX` — `INDEX(array, row_num, [column_num], [area_num])`
- `INDIRECT` — `INDIRECT(ref_text, [a1])`
- `LOOKUP` — `LOOKUP(lookup_value, lookup_vector, [result_vector])`
- `MATCH` — `MATCH(lookup_value, lookup_array, [match_type])`
- `OFFSET` — `OFFSET(reference, rows, cols, [height], [width])`
- `PIVOTBY` — `PIVOTBY(row_fields, col_fields, values, function, [field_headers], [row_total_depth], [row_sort_order], [col_total_depth], [col_sort_order], [filter_array], [relative_to])`
- `ROW` — `ROW([reference])`
- `ROWS` — `ROWS(array)`
- `SORT` — `SORT(array, [sort_index], [sort_order], [by_col])`
- `SORTBY` — `SORTBY(array, by_array1, [sort_order1], ...)`
- `TAKE` — `TAKE(array, rows, [columns])`
- `TOCOL` — `TOCOL(array, [ignore], [scan_by_column])`
- `TOROW` — `TOROW(array, [ignore], [scan_by_column])`
- `TRANSPOSE` — `TRANSPOSE(array)`
- `TRIMRANGE` — `TRIMRANGE(range, [trim_rows], [trim_cols])`
- `UNIQUE` — `UNIQUE(array, [by_col], [exactly_once])`
- `VLOOKUP` — `VLOOKUP(lookup_value, table_array, col_index_num, [range_lookup])`
- `VSTACK` — `VSTACK(array1, [array2], ...)`
- `WRAPCOLS` — `WRAPCOLS(vector, wrap_count, [pad_with])`
- `WRAPROWS` — `WRAPROWS(vector, wrap_count, [pad_with])`
- `XLOOKUP` — `XLOOKUP(lookup_value, lookup_array, return_array, [if_not_found], [match_mode], [search_mode])`
- `XMATCH` — `XMATCH(lookup_value, lookup_array, [match_mode], [search_mode])`

## MathTrig

- `ABS` — `ABS(number)`
- `ACOS` — `ACOS(number)`
- `ACOSH` — `ACOSH(number)`
- `ACOT` — `ACOT(number)`
- `ACOTH` — `ACOTH(number)`
- `AGGREGATE` — `AGGREGATE(function_num, options, ref1, ...)`
- `ARABIC` — `ARABIC(text)`
- `ASIN` — `ASIN(number)`
- `ASINH` — `ASINH(number)`
- `ATAN` — `ATAN(number)`
- `ATAN2` — `ATAN2(x_num, y_num)`
- `ATANH` — `ATANH(number)`
- `BASE` — `BASE(number, radix, [min_length])`
- `CEILING.MATH` — `CEILING.MATH(number, [significance], [mode])`
- `CEILING.PRECISE` — `CEILING.PRECISE(number, [significance])`
- `COMBIN` — `COMBIN(number, number_chosen)`
- `COMBINA` — `COMBINA(number, number_chosen)`
- `COS` — `COS(number)`
- `COSH` — `COSH(number)`
- `COT` — `COT(number)`
- `COTH` — `COTH(number)`
- `CSC` — `CSC(number)`
- `CSCH` — `CSCH(number)`
- `DECIMAL` — `DECIMAL(text, radix)`
- `DEGREES` — `DEGREES(angle)`
- `EVEN` — `EVEN(number)`
- `EXP` — `EXP(number)`
- `FACT` — `FACT(number)`
- `FACTDOUBLE` — `FACTDOUBLE(number)`
- `FLOOR.MATH` — `FLOOR.MATH(number, [significance], [mode])`
- `FLOOR.PRECISE` — `FLOOR.PRECISE(number, [significance])`
- `GCD` — `GCD(number1, [number2], ...)`
- `INT` — `INT(number)`
- `ISO.CEILING` — `ISO.CEILING(number, [significance])`
- `LCM` — `LCM(number1, [number2], ...)`
- `LN` — `LN(number)`
- `LOG` — `LOG(number, [base])`
- `LOG10` — `LOG10(number)`
- `MDETERM` — `MDETERM(array)`
- `MINVERSE` — `MINVERSE(array)`
- `MMULT` — `MMULT(array1, array2)`
- `MOD` — `MOD(number, divisor)`
- `MROUND` — `MROUND(number, multiple)`
- `MULTINOMIAL` — `MULTINOMIAL(number1, [number2], ...)`
- `MUNIT` — `MUNIT(dimension)`
- `ODD` — `ODD(number)`
- `PERCENTOF` — `PERCENTOF(data_subset, data_all)`
- `PI` — `PI()`
- `POWER` — `POWER(number, power)`
- `PRODUCT` — `PRODUCT(number1, [number2], ...)`
- `QUOTIENT` — `QUOTIENT(numerator, denominator)`
- `RADIANS` — `RADIANS(angle)`
- `RAND` — `RAND()`
- `RANDARRAY` — `RANDARRAY([rows], [columns], [min], [max], [whole_number])`
- `RANDBETWEEN` — `RANDBETWEEN(bottom, top)`
- `ROMAN` — `ROMAN(number, [form])`
- `ROUND` — `ROUND(number, num_digits)`
- `ROUNDDOWN` — `ROUNDDOWN(number, num_digits)`
- `ROUNDUP` — `ROUNDUP(number, num_digits)`
- `SEC` — `SEC(number)`
- `SECH` — `SECH(number)`
- `SEQUENCE` — `SEQUENCE(rows, [columns], [start], [step])`
- `SERIESSUM` — `SERIESSUM(x, n, m, coefficients)`
- `SIGN` — `SIGN(number)`
- `SIN` — `SIN(number)`
- `SINH` — `SINH(number)`
- `SQRT` — `SQRT(number)`
- `SQRTPI` — `SQRTPI(number)`
- `SUBTOTAL` — `SUBTOTAL(function_num, ref1, ...)`
- `SUM` — `SUM(number1, [number2], ...)`
- `SUMIF` — `SUMIF(range, criteria, [sum_range])`
- `SUMIFS` — `SUMIFS(sum_range, criteria_range1, criteria1, ...)`
- `SUMPRODUCT` — `SUMPRODUCT(array1, [array2], ...)`
- `SUMSQ` — `SUMSQ(number1, [number2], ...)`
- `SUMX2MY2` — `SUMX2MY2(array_x, array_y)`
- `SUMX2PY2` — `SUMX2PY2(array_x, array_y)`
- `SUMXMY2` — `SUMXMY2(array_x, array_y)`
- `TAN` — `TAN(number)`
- `TANH` — `TANH(number)`
- `TRUNC` — `TRUNC(number, [num_digits])`

## Statistical

- `AVEDEV` — `AVEDEV(number1, [number2], ...)`
- `AVERAGE` — `AVERAGE(number1, [number2], ...)`
- `AVERAGEA` — `AVERAGEA(value1, [value2], ...)`
- `AVERAGEIF` — `AVERAGEIF(range, criteria, [average_range])`
- `AVERAGEIFS` — `AVERAGEIFS(average_range, criteria_range1, criteria1, ...)`
- `BETA.DIST` — `BETA.DIST(x, alpha, beta, cumulative, [A], [B])`
- `BETA.INV` — `BETA.INV(probability, alpha, beta, [A], [B])`
- `BINOM.DIST` — `BINOM.DIST(number_s, trials, probability_s, cumulative)`
- `BINOM.DIST.RANGE` — `BINOM.DIST.RANGE(trials, probability_s, number_s, [number_s2])`
- `BINOM.INV` — `BINOM.INV(trials, probability_s, alpha)`
- `CHISQ.DIST` — `CHISQ.DIST(x, deg_freedom, cumulative)`
- `CHISQ.DIST.RT` — `CHISQ.DIST.RT(x, deg_freedom)`
- `CHISQ.INV` — `CHISQ.INV(probability, deg_freedom)`
- `CHISQ.INV.RT` — `CHISQ.INV.RT(probability, deg_freedom)`
- `CHISQ.TEST` — `CHISQ.TEST(actual_range, expected_range)`
- `CONFIDENCE.NORM` — `CONFIDENCE.NORM(alpha, standard_dev, size)`
- `CONFIDENCE.T` — `CONFIDENCE.T(alpha, standard_dev, size)`
- `CORREL` — `CORREL(array1, array2)`
- `COUNT` — `COUNT(value1, [value2], ...)`
- `COUNTA` — `COUNTA(value1, [value2], ...)`
- `COUNTBLANK` — `COUNTBLANK(range)`
- `COUNTIF` — `COUNTIF(range, criteria)`
- `COUNTIFS` — `COUNTIFS(criteria_range1, criteria1, ...)`
- `COVARIANCE.P` — `COVARIANCE.P(array1, array2)`
- `COVARIANCE.S` — `COVARIANCE.S(array1, array2)`
- `DEVSQ` — `DEVSQ(number1, [number2], ...)`
- `EXPON.DIST` — `EXPON.DIST(x, lambda, cumulative)`
- `F.DIST` — `F.DIST(x, deg_freedom1, deg_freedom2, cumulative)`
- `F.DIST.RT` — `F.DIST.RT(x, deg_freedom1, deg_freedom2)`
- `F.INV` — `F.INV(probability, deg_freedom1, deg_freedom2)`
- `F.INV.RT` — `F.INV.RT(probability, deg_freedom1, deg_freedom2)`
- `F.TEST` — `F.TEST(array1, array2)`
- `FISHER` — `FISHER(x)`
- `FISHERINV` — `FISHERINV(y)`
- `FORECAST.ETS` — `FORECAST.ETS(target_date, values, timeline, [seasonality], [data_completion], [aggregation])`
- `FORECAST.ETS.CONFINT` — `FORECAST.ETS.CONFINT(target_date, values, timeline, [confidence_level], [seasonality], [data_completion], [aggregation])`
- `FORECAST.ETS.SEASONALITY` — `FORECAST.ETS.SEASONALITY(values, timeline, [data_completion], [aggregation])`
- `FORECAST.ETS.STAT` — `FORECAST.ETS.STAT(values, timeline, statistic_type, [seasonality], [data_completion], [aggregation])`
- `FORECAST.LINEAR` — `FORECAST.LINEAR(x, known_ys, known_xs)`
- `FREQUENCY` — `FREQUENCY(data_array, bins_array)`
- `GAMMA` — `GAMMA(number)`
- `GAMMA.DIST` — `GAMMA.DIST(x, alpha, beta, cumulative)`
- `GAMMA.INV` — `GAMMA.INV(probability, alpha, beta)`
- `GAMMALN` — `GAMMALN(x)`
- `GAMMALN.PRECISE` — `GAMMALN.PRECISE(x)`
- `GAUSS` — `GAUSS(z)`
- `GEOMEAN` — `GEOMEAN(number1, [number2], ...)`
- `GROWTH` — `GROWTH(known_ys, [known_xs], [new_xs], [const])`
- `HARMEAN` — `HARMEAN(number1, [number2], ...)`
- `HYPGEOM.DIST` — `HYPGEOM.DIST(sample_s, number_sample, population_s, number_pop, cumulative)`
- `INTERCEPT` — `INTERCEPT(known_ys, known_xs)`
- `KURT` — `KURT(number1, [number2], ...)`
- `LARGE` — `LARGE(array, k)`
- `LINEST` — `LINEST(known_ys, [known_xs], [const], [stats])`
- `LOGEST` — `LOGEST(known_ys, [known_xs], [const], [stats])`
- `LOGNORM.DIST` — `LOGNORM.DIST(x, mean, standard_dev, cumulative)`
- `LOGNORM.INV` — `LOGNORM.INV(probability, mean, standard_dev)`
- `MAX` — `MAX(number1, [number2], ...)`
- `MAXA` — `MAXA(value1, [value2], ...)`
- `MAXIFS` — `MAXIFS(max_range, criteria_range1, criteria1, ...)`
- `MEDIAN` — `MEDIAN(number1, [number2], ...)`
- `MIN` — `MIN(number1, [number2], ...)`
- `MINA` — `MINA(value1, [value2], ...)`
- `MINIFS` — `MINIFS(min_range, criteria_range1, criteria1, ...)`
- `MODE.MULT` — `MODE.MULT(number1, [number2], ...)`
- `MODE.SNGL` — `MODE.SNGL(number1, [number2], ...)`
- `NEGBINOM.DIST` — `NEGBINOM.DIST(number_f, number_s, probability_s, cumulative)`
- `NORM.DIST` — `NORM.DIST(x, mean, standard_dev, cumulative)`
- `NORM.INV` — `NORM.INV(probability, mean, standard_dev)`
- `NORM.S.DIST` — `NORM.S.DIST(z, cumulative)`
- `NORM.S.INV` — `NORM.S.INV(probability)`
- `PEARSON` — `PEARSON(array1, array2)`
- `PERCENTILE.EXC` — `PERCENTILE.EXC(array, k)`
- `PERCENTILE.INC` — `PERCENTILE.INC(array, k)`
- `PERCENTRANK.EXC` — `PERCENTRANK.EXC(array, x, [significance])`
- `PERCENTRANK.INC` — `PERCENTRANK.INC(array, x, [significance])`
- `PERMUT` — `PERMUT(number, number_chosen)`
- `PERMUTATIONA` — `PERMUTATIONA(number, number_chosen)`
- `PHI` — `PHI(x)`
- `POISSON.DIST` — `POISSON.DIST(x, mean, cumulative)`
- `PROB` — `PROB(x_range, prob_range, lower_limit, [upper_limit])`
- `QUARTILE.EXC` — `QUARTILE.EXC(array, quart)`
- `QUARTILE.INC` — `QUARTILE.INC(array, quart)`
- `RANK.AVG` — `RANK.AVG(number, ref, [order])`
- `RANK.EQ` — `RANK.EQ(number, ref, [order])`
- `RSQ` — `RSQ(known_ys, known_xs)`
- `SKEW` — `SKEW(number1, [number2], ...)`
- `SKEW.P` — `SKEW.P(number1, [number2], ...)`
- `SLOPE` — `SLOPE(known_ys, known_xs)`
- `SMALL` — `SMALL(array, k)`
- `STANDARDIZE` — `STANDARDIZE(x, mean, standard_dev)`
- `STDEV.P` — `STDEV.P(number1, [number2], ...)`
- `STDEV.S` — `STDEV.S(number1, [number2], ...)`
- `STDEVA` — `STDEVA(value1, [value2], ...)`
- `STDEVPA` — `STDEVPA(value1, [value2], ...)`
- `STEYX` — `STEYX(known_ys, known_xs)`
- `T.DIST` — `T.DIST(x, deg_freedom, cumulative)`
- `T.DIST.2T` — `T.DIST.2T(x, deg_freedom)`
- `T.DIST.RT` — `T.DIST.RT(x, deg_freedom)`
- `T.INV` — `T.INV(probability, deg_freedom)`
- `T.INV.2T` — `T.INV.2T(probability, deg_freedom)`
- `T.TEST` — `T.TEST(array1, array2, tails, type)`
- `TREND` — `TREND(known_ys, [known_xs], [new_xs], [const])`
- `TRIMMEAN` — `TRIMMEAN(array, percent)`
- `VAR.P` — `VAR.P(number1, [number2], ...)`
- `VAR.S` — `VAR.S(number1, [number2], ...)`
- `VARA` — `VARA(value1, [value2], ...)`
- `VARPA` — `VARPA(value1, [value2], ...)`
- `WEIBULL.DIST` — `WEIBULL.DIST(x, alpha, beta, cumulative)`
- `Z.TEST` — `Z.TEST(array, x, [sigma])`

## Text

- `ARRAYTOTEXT` — `ARRAYTOTEXT(array, [format])`
- `ASC` — `ASC(text)`
- `BAHTTEXT` — `BAHTTEXT(number)`
- `CHAR` — `CHAR(number)`
- `CLEAN` — `CLEAN(text)`
- `CODE` — `CODE(text)`
- `CONCAT` — `CONCAT(text1, [text2], ...)`
- `CONCATENATE` — `CONCATENATE(text1, [text2], ...)`
- `DBCS` — `DBCS(text)`
- `DOLLAR` — `DOLLAR(number, [decimals])`
- `EXACT` — `EXACT(text1, text2)`
- `FIND` — `FIND(find_text, within_text, [start_num])`
- `FINDB` — `FINDB(find_text, within_text, [start_num])`
- `FIXED` — `FIXED(number, [decimals], [no_commas])`
- `JIS` — `JIS(text)`
- `LEFT` — `LEFT(text, [num_chars])`
- `LEFTB` — `LEFTB(text, [num_bytes])`
- `LEN` — `LEN(text)`
- `LENB` — `LENB(text)`
- `LOWER` — `LOWER(text)`
- `MID` — `MID(text, start_num, num_chars)`
- `MIDB` — `MIDB(text, start_num, num_bytes)`
- `NUMBERVALUE` — `NUMBERVALUE(text, [decimal_separator], [group_separator])`
- `PHONETIC` — `PHONETIC(reference)`
- `PROPER` — `PROPER(text)`
- `REGEXEXTRACT` — `REGEXEXTRACT(text, pattern, [return_mode], [case_sensitivity])`
- `REGEXREPLACE` — `REGEXREPLACE(text, pattern, replacement, [occurrence], [case_sensitivity])`
- `REGEXTEST` — `REGEXTEST(text, pattern, [case_sensitivity])`
- `REPLACE` — `REPLACE(old_text, start_num, num_chars, new_text)`
- `REPLACEB` — `REPLACEB(old_text, start_num, num_bytes, new_text)`
- `REPT` — `REPT(text, number_times)`
- `RIGHT` — `RIGHT(text, [num_chars])`
- `RIGHTB` — `RIGHTB(text, [num_bytes])`
- `SEARCH` — `SEARCH(find_text, within_text, [start_num])`
- `SEARCHB` — `SEARCHB(find_text, within_text, [start_num])`
- `SUBSTITUTE` — `SUBSTITUTE(text, old_text, new_text, [instance_num])`
- `T` — `T(value)`
- `TEXT` — `TEXT(value, format_text)`
- `TEXTAFTER` — `TEXTAFTER(text, delimiter, [instance_num], [match_mode], [match_end], [if_not_found])`
- `TEXTBEFORE` — `TEXTBEFORE(text, delimiter, [instance_num], [match_mode], [match_end], [if_not_found])`
- `TEXTJOIN` — `TEXTJOIN(delimiter, ignore_empty, text1, [text2], ...)`
- `TEXTSPLIT` — `TEXTSPLIT(text, col_delimiter, [row_delimiter], [ignore_empty], [match_mode], [pad_with])`
- `TRIM` — `TRIM(text)`
- `UNICHAR` — `UNICHAR(number)`
- `UNICODE` — `UNICODE(text)`
- `UPPER` — `UPPER(text)`
- `VALUE` — `VALUE(text)`
- `VALUETOTEXT` — `VALUETOTEXT(value, [format])`

## Web

- `ENCODEURL` — `ENCODEURL(text)`
- `FILTERXML` — `FILTERXML(xml, xpath)`
- `WEBSERVICE` — `WEBSERVICE(url)`
