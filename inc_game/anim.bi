type anim_type
	private:
	dim as integer active = 0
	dim as double tFrame = 0.0
	dim as integer iFrame = 0
	dim as double tFrameDuration = 0.50
	dim as image_type ptr pImgArray 'array of images, point to first
	dim as image_type ptr ptr ppTargetImg
	dim as integer numImages 'number of image to cycle / size of array
	dim as integer iLoop, numLoops
	public:
	declare sub init(byref ppTargetImg as image_type ptr)
	declare sub start(pImgArray as image_type ptr, numImages as integer, numLoops as integer, tFrameDuration as double)
	declare sub update(dt as double)
	declare sub stop_(pImgArray as image_type ptr)
end type

sub anim_type.init(byref pPlayerImg as image_type ptr)
	ppTargetImg = @pPlayerImg
end sub

'call: start(first image of array, nummer of images in array, number of animation loops, frame display time)
sub anim_type.start(pImgArray as image_type ptr, numImages as integer, numLoops as integer, tFrameDuration as double)
	tFrame = 0.0
	iFrame = 0
	this.tFrameDuration = tFrameDuration
	this.numImages = numImages
	this.numLoops = numLoops
	this.pImgArray = pImgArray
	*ppTargetImg = pImgArray 'set target image
	active = 1
	iLoop = 0
end sub

sub anim_type.update(dt as double)
	if active = 0 then exit sub
	tFrame += dt
	if tFrame > tFrameDuration then
		tFrame = 0.0 'change to tFrame -= tFrameDuration ?
		iFrame += 1
		if iFrame >= numImages then
			iFrame = 0
			iLoop += 1
			if numLoops > 0 and iLoop >= numLoops then active = 0
		end if
		*ppTargetImg = pImgArray + iFrame 'update current miner image
	end if
end sub

'call: stop(optional new image to set)
sub anim_type.stop_(pImgArray as image_type ptr)
	active = 0
	if pImgArray <> 0 then *ppTargetImg = pImgArray
end sub
