function data = prepData(currentData)
% Convert types, units, and organize data for machine learning

% Convert data type
data = convertData(currentData);

% Calculate dew point from temp and relative humidity
data.DP = data.T-(9/25)*(100-data.RH);

% Convert Kelvin to Celsius
data.T = data.T - 273.15;

% Convert date
if ~isa(data.DateLocal,"datetime")
    if strlength(data.DateLocal) > 20
        data.DateLocal = datetime(data.DateLocal,...
            "InputFormat","uuuu-MM-dd HH:mm:ss.SSS");
    else
        data.DateLocal = datetime(data.DateLocal);
    end
end
% Split date into components for machine learning
[data.yy,data.MM,data.dd] = ymd(data.DateLocal);

% Figure out the US State from the city name and lat/lon using data from:
% https://simplemaps.com/data/us-cities.
switch data.city
    case "San Jose"
        data.StateName = "California";
    case "Washington DC."
        data.StateName = "District of Columbia";
    case "Boston"
        data.StateName = "Massachusetts";
    case "Munich"
        data.StateName = "Bayern";
    case "London"
        data.StateName = "UK";
    otherwise
        load cities city
        idx = city.city == data.city & ...
            round(city.lat) == round(data.lat) & ...
            round(city.lng) == round(data.lon);
        data.StateName = city.state_name(idx);
end
% Convert state to categorical
data.StateName = categorical(data.StateName);

% Select data for model prediction
data = data(:,["DateLocal","city","StateName","T","P",...
    "DP","RH","WindDir","WindSpd","yy","MM","dd"]);
end

function data = convertData(data)
% Organize and convert data types 
data = struct2table(struct(data));
% Check for wind direction (deg), sometimes missing
if ~any(data.Properties.VariableNames == "deg")
    deg = "";
    data = addvars(data,deg,'After','speed');
end
data = removevars(data,["temp_min","temp_max"]);
data.Properties.VariableNames([1:5,end]) = ["T","P","RH","WindSpd","WindDir","DateLocal"];
data = convertvars(data,["T","P","RH","WindSpd","WindDir"],"double");
data = convertvars(data,["city","DateLocal"],"string");

% Convert date
if strlength(data.DateLocal) > 20
    data.DateLocal = datetime(data.DateLocal,"InputFormat","uuuu-MM-dd HH:mm:ss.SSS");
else
    data.DateLocal = datetime(data.DateLocal);
end

end