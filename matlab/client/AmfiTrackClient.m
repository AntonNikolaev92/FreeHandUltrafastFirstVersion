% External Client to receive AmfiTrack positions %
close all
clear all

addpath('E:\tools\jtcp');

path = 'E:\projects\FreeHandUltrafast\Verasonics';


port = 5555;
ipaddr = '192.168.0.101';
szUSB = 64;
jTcpObj = [];

nFrames = [];
rcvBuf = [];

try
    jTcpObj = jtcp('request',ipaddr,port,'timeout',10000,'serialize',false);
    
    % receive position buffer
    while length(rcvBuf) < 4
        mssg = jtcp('read',jTcpObj);
        rcvBuf = [ rcvBuf, mssg ];
    end
    nFrames = typecast(rcvBuf(1:4),'uint32');
    nBytesToRead = nFrames*(4+szUSB);
    fprintf('Frames to receive: %i (%i)\n', nFrames, nBytesToRead);
    while length(rcvBuf) < nBytesToRead
        mssg = jtcp('read',jTcpObj);
        rcvBuf = [ rcvBuf, mssg ];
    end
catch
    if ~isempty(jTcpObj), jtcp('close', jTcpObj); end;
    disp('something went wrong');
    return;
end

posBuf = rcvBuf(5: (nFrames*szUSB));
posHex = dec2hex(typecast(posBuf,'uint8'));
tsBuf = rcvBuf((nFrames*szUSB+1):(nFrames*4));
[ t, q ] = usbdata2pos(rcvBuf(2: (nFrames*szUSB) ), szUSB);
ts = typecast(rcvBuf( (nFrames*szUSB+1):(nFrames*4) ),'int8');

fhData.pos.ts = typecast(tsData,'int64');
[ fhData.pos.t, fhData.pos.q ] = usbdata2pos( typecast(posData,'uint8'), 64 );

% Interpolate Coordinates with respect to acquisition frames

[~,nFramesPos] = size(fhData.pos.t);
tmpPos = fhData.pos.t;
iFramePos  = 1;
tmpPos = t;
for iFramePosHlp = 1:nFramesPos
    if ( tmpPos(1,iFramePos) < -1e+4 ) || ( tmpPos(1,iFramePos ) > 1e+4 )||...
          ( tmpPos(2,iFramePos) < -1e+4 ) || ( tmpPos(2,iFramePos ) > 1e+4 )|| ...
          ( tmpPos(3,iFramePos) < -1e+4 ) || ( tmpPos(3,iFramePos ) > 1e+4 )
        tmpPos(:,iFramePos) = [];
        nFramesPos = nFramesPos - 1;
        iFramePos = iFramePos - 1;
    end
    iFramePos = iFramePos + 1;
end


subplot(3,3,1); plot(t(1,:)); ylabel('tx');
subplot(3,3,2); plot(t(2,:)); ylabel('ty');
subplot(3,3,3); plot(t(3,:)); ylabel('tz');
subplot(3,3,4); plot(q(1,:)); ylabel('qx');
subplot(3,3,5); plot(q(2,:)); ylabel('qy');
subplot(3,3,6); plot(q(3,:)); ylabel('qz');
subplot(3,3,7); plot(ts);


