//
//  CMPSKMatchedFilter.m
//  CoreModem
//
//  Created by Kok Chen on 11/02/05
//	Based on cococaModem, original file dated Wed Aug 11 2004.
	#include "Copyright.h"

#import "CMPSKMatchedFilter.h"
#include "CMPCO.h"
#include "CMDSPWindow.h"


@implementation CMPSKMatchedFilter

#define Nt   20		//  closest integer to a bit time

static int hw[] = { 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4 } ;

static int hammingWeight( int p )
{
	if ( p & 0xffff0000 ) {
		return hammingWeight( ( p > 16 ) & 0xffff ) + hammingWeight( p & 0xffff ) ;
	}
	if ( p & 0xff00 ) {
		return hammingWeight( p >> 8 ) + hammingWeight( p & 0xff ) ;
	}
	return hw[ p >> 4 ] + hw[ p & 0xf ] ;
}


#ifndef MAKEQPSKTABLE
static char QPSKTable[1024] = {
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	0x1,	
	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	0x0,	
} ;

// generate table for QPSK31 decoding
static void generateQPSKTable( char *output )
{
	memcpy( output, QPSKTable, 1024 ) ;
}
#else
static void generateQPSKTable( char *output )
{
	int i, j, bit, sr, g, g0, g1, s0, s1, index, dist, count ;
	int table[1024] ;
	float accum ;
	
	for ( i = 0; i < 1024; i++ ) table[i] = -1 ;
	
	//  run through all 9-bit combinations
	//  ....x....  where x is the output bit
	
	for ( i = 0; i < 512; i++ ) {
		bit = ( i & 0x10 ) ? 0 : 1 ;  // notice inverted data bit
		sr = i ;
		s0 = s1 = 0 ;
		
		//  for j = 0, generate output vector for ....45678
		//  for j = 1, generate output vector for ...34567.
		//  for j = 2, generate output vector for ..23456..
		//  etc
		
		//  bit 4 is the target bit
		
		for ( j = 0; j < 5; j++ ) {
			g = sr & 0x1f ;
			g0 = g1 = 0 ;
			
			g1 ^= ( g & 0x1 ) ? 2 : 0 ;
			g1 ^= ( g & 0x8 ) ? 2 : 0 ;
			g1 ^= ( g & 0x10 ) ? 2 : 0 ;
			
			g0 ^= ( g & 0x1 ) ? 1 : 0 ;
			g0 ^= ( g & 0x2 ) ? 1 : 0 ;
			g0 ^= ( g & 0x4 ) ? 1 : 0 ;
			g0 ^= ( g & 0x10 ) ? 1 : 0 ;
			
			// Exchange the original 10 (180 degree) and 11 (-90 degree) mapping
			//  to make Hamming distance agree with phase error
			g0 = g0 ^ ( g1 >> 1 ) ;		
			
			s0 |= g0 << j*2 ;
			s1 |= g1 << j*2 ;
			
			sr >>= 1 ;
		}
		
		if ( ( s0 & s1 ) != 0 ) {
			printf( "bit overlap!\n" ) ;
			return ;
		}
		
		//  index is s1|s0|s1|s0|s1|s0...s1|s0 (5 vectors or 10 bits total)
		index = s0 + s1 ;
		if ( table[index] != -1 ) {
			//  sanity check
			printf( "table overlap!\n" ) ;
			return ;
		}
		table[index] = bit ;
	}
	//  at this point 512 elements of the 1024 table are defined.
	
	for ( i = 0; i < 1024; i++ ) {
		if ( table[i] < 0 ) {
			//  find closest matches
			accum = 0 ;
			count = 0 ;
			for ( j = 0; j < 1024; j++ ) {
				if ( table[j] >= 0 ) {
					dist = hammingWeight( i ^ j ) ;
					if ( dist <= 1 ) {
						count++ ;
						accum += table[j] ;
					}
				}
			}
			bit = ( accum/count > 0.5 ) ? 1 : 0 ;
			table[i] = bit ;
		}
	}
	for ( i = 0; i < 1024; i++ ) {
		//  now flip bits back (10 for 180 degrees, 11 for -90 degrees)
		j = i ;
		if ( j & 0x200 ) j ^= 0x100 ;
		if ( j & 0x80 ) j ^= 0x40 ;
		if ( j & 0x20 ) j ^= 0x10 ;
		if ( j & 0x8 ) j ^= 0x4 ;
		if ( j & 0x2 ) j ^= 0x1 ;
		output[j] = table[i] ;
	}
	printf( "----\n" ) ;
	for ( i = 0; i < 1024; i++ ) {
		printf( "0x%x,\t", output[i] ) ;
		if ( ( i % 16 ) == 15 ) printf( "\n" ) ;
	}
}
#endif

- (id)init
{
	int i ;
	float period, p, sum ;
	
	self = [ super init ] ;
	if ( self ) {
		delegate = nil ;
		
		//  set up DataStream
		data = &mfStream ;
		mfStream.array = &demodulated[0] ;
		mfStream.samplingRate = CMFs/16 ;
		mfStream.samples = 256 ;
		mfStream.components = 1 ;
		mfStream.channels = 2 ;
		
		iMatched = qMatched = 0 ;
		bitPhase = 0 ;
		//  ring buffer
		ring = 0 ;
		for ( i = 0; i < RING+1; i++ ) matchedI[i] = matchedQ[i] ;
		//  raised cosine kernel
		period = CMFs/16.0/31.25 ;
		midBit = period/2 ;
		for ( i = 0; i < 64; i++ ) {
			kernel[i] = 0 ;
			p = i/period ;
			if ( p < 1.0 ) kernel[i] = ( 1.0 - cos( p*2*3.1415926 ) )*0.5 ;
		}
		for ( sum = 0, i = 0; i < 64; i++ ) sum += kernel[i] ;
		for ( i = 0; i < 64; i++ ) kernel[i] /= sum ;
		
		//  narrow raised cosine kernel (60% the width of a bit period)
		for ( i = 0; i < 64; i++ ) {
			pulse[i] = 0 ;
			p = i/period ;
			if ( p > 0.2 && p < 0.8 ) pulse[i] = ( 1.0 - cos( (p-0.2)*2*3.1415926535/0.6 ) )*0.5 ;
		}
		for ( sum = 0, i = 0; i < 64; i++ ) sum += pulse[i] ;
		for ( i = 0; i < 64; i++ ) pulse[i] /= sum ;
						
		delta = 0 ;
		
		iLast = qLast = 1.0 ;
		convolutionRegister = 0 ;
		generateQPSKTable( qpskTable ) ;
	}
	return self ;
}

#define twopi   ( 3.1415926535*2 )

- (float)bpskEstimate:(float*)bufI imag:(float*)bufQ
{
	int p0, p1, p2 ;
	float dot, refI, refQ, g, pI, pQ ;
	
	p0 = ring ;
	p1 = ( ring+RING )&RING ;		//  p0-1
	p2 = ( ring+RING-1 )&RING ;		//  p0-2
	//  establish reference vector from three vectors
	refI = pI = bufI[p2] ;
	refQ = pQ = bufQ[p2] ;
	g = ( ( pI*bufI[p1] + pQ*bufQ[p1] ) < 0 ) ? ( -1 ) : 1 ;
	refI += bufI[p1]*g ;
	refQ += bufQ[p1]*g ;
	g = ( ( pI*bufI[p0] + pQ*bufQ[p0] ) < 0 ) ? ( -1 ) : 1 ;
	refI += bufI[p0]*g ;
	refQ += bufQ[p0]*g ;
	
	dot = refI*bufI[p1] + refQ*bufQ[p1] ;
	return dot ;
}

/* local */
//  estimate the phase angle from a combination of matched filter, narrow matched filter and a single mid bit ssample
- (int)processBpskVector
{
	float matchedBit ;
	int result ;
	
	//  estmate from matched filter
	matchedI[ring] = iMatched ;
	matchedQ[ring] = qMatched ;
	matchedBit = 0.5*[ self bpskEstimate:matchedI imag:matchedQ ] ;

	//  estmate from narrow raised cosine
	pulseI[ring] = iPulse ;
	pulseQ[ring] = qPulse ;
	matchedBit += 1.0*[ self bpskEstimate:pulseI imag:pulseQ ] ;

	//  estimate from mid bit sample
	midI[ring] = iMid ;
	midQ[ring] = qMid ;
	matchedBit += 0.1*[ self bpskEstimate:midI imag:midQ ] ;
	
	result = ( matchedBit > 0.0 ) ? 1 : 0 ;
	[ self receivedBit:result ] ;
	
	//  update ring buffer indeces
	ring = ( ring+1 )&RING ;
	return result ;
}

/* local */
//  estimate the phase angle from a narrow matched filter
- (int)processQpskVector
{
	float iLastRotated, qLastRotated, dot, dotRotated ;
	int result, symbol ;
	
	//  estmate delta from narrow raised cosine kernel
	iLastRotated = -qLast ;
	qLastRotated = iLast ;
	
	dot = iLast*iPulse + qLast*qPulse ;
	dotRotated = iLastRotated*iPulse + qLastRotated*qPulse ;

	if ( fabs( dot ) > fabs( dotRotated ) ) {
		//  0 or 180 degrees
		symbol = ( dot > 0 ) ? 0 : 2 ;
	}
	else {
		//  plus or minus 90 degrees
		symbol = ( dotRotated > 0 ) ? 1 : 3 ;
	}
	//  shift bits into shift register
	convolutionRegister = ( ( convolutionRegister << 2 ) | symbol ) & 0x3ff ;
	result = qpskTable[ convolutionRegister ] ;
	[ self receivedBit:result ] ;
	
	//  save vector for next bit
	iLast = iPulse ;
	qLast = qPulse ;
	//  update ring buffer indeces
	ring = ( ring+1 )&RING ;
	return result ;
}

- (float)phaseError
{
	if ( delta > 0 ) return ( delta-3.1415926 ) ;
	return ( delta+3.1415926 ) ;
}

//  send current phase to delegate
- (void)updateVCOPhase:(float)ang
{
	if ( delegate && [ delegate respondsToSelector:@selector(updateVCOPhase:) ] ) [ delegate updateVCOPhase:ang ] ;
}

//  send current phase to delegate
- (void)receivedBit:(int)bit
{
	if ( delegate && [ delegate respondsToSelector:@selector(receivedBit:) ] ) [ delegate receivedBit:bit ] ;
}

//  new analytic pair at Fs/16
//  start is a flag that indicates the estimated boundary between data bits
//	(i.e., during a transition, the analytic pair at start should be very close to (0,0))
- (int)bpsk:(float)real imag:(float)imag bitPhase:(Boolean)start
{
	float h ;
	int result ;
	
	//  integrate
	h = kernel[ bitPhase & 0x3f ] ;
	iMatched += real*h ;
	qMatched += imag*h ;

	h = pulse[ bitPhase & 0x3f ] ;
	iPulse += real*h ;
	qPulse += imag*h ;

	bitPhase++ ;
	result = 0 ;
	
	if ( start ) {
		result = [ self processBpskVector ] ;
		// dump
		iMatched = qMatched = iPulse = qPulse = 0 ;
		bitPhase = 0 ;
	}
	//  no need to update phase if there is no delegate
	if ( delegate && bitPhase == midBit ) {
		iMid = real ;
		qMid = imag ;
		//  compute absolute phase angle
		phase[0] = atan2( imag, real ) ;
		//  compute relative phase angle
		delta = phase[0]-phase[1] ;
		if ( delta > pi ) delta = twopi - delta ; else if ( delta < -pi ) delta = twopi + delta ;
		[ self updateVCOPhase:delta ] ;
		phase[1] = phase[0] ;
	}
	return result ;
}

//  new analytic pair at Fs/16
- (int)qpsk:(float)real imag:(float)imag bitPhase:(Boolean)start
{
	float h ;
	int result ;
	
	h = pulse[ bitPhase & 0x3f ] ;
	iPulse += real*h ;
	qPulse += imag*h ;

	bitPhase++ ;
	result = 0 ;
	
	if ( start ) {
		result = [ self processQpskVector ] ;
		// dump
		iPulse = qPulse = 0 ;
		bitPhase = 0 ;
	}
	if ( delegate && bitPhase == midBit ) {
		iMid = real ;
		qMid = imag ;
		//  compute absolute phase angle
		phase[0] = atan2( imag, real ) ;
		//  compute relative phase angle
		delta = phase[0]-phase[1] ;
		if ( delta > pi ) delta = twopi - delta ; else if ( delta < -pi ) delta = twopi + delta ;
		[ self updateVCOPhase:delta ] ;
		phase[1] = phase[0] ;
	}	
	return result ;
}

//  import data pipe is not used.  The PSK receiver calls -inPhase:quadrature:size:
- (void)importData:(CMPipe*)pipe
{	
}

- (id)delegate
{
	return delegate ;
}

- (void)setDelegate:(id)inDelegate
{
	delegate = inDelegate ;
}

@end