#include "factor.h"

void primitive_fixnump(void)
{
	drepl(tag_boolean(TAG(dpeek()) == FIXNUM_TYPE));
}

FIXNUM to_fixnum(CELL tagged)
{
	RATIO* r;
	FLOAT* f;

	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return untag_fixnum_fast(tagged);
	case BIGNUM_TYPE:
		return bignum_to_fixnum(tagged);
	case RATIO_TYPE:
		r = (RATIO*)UNTAG(tagged);
		return to_fixnum(divint(r->numerator,r->denominator));
	case FLOAT_TYPE:
		f = (FLOAT*)UNTAG(tagged);
		return (FIXNUM)f->n;
	default:
		type_error(FIXNUM_TYPE,tagged);
		return -1; /* can't happen */
	}
}

void primitive_to_fixnum(void)
{
	drepl(tag_fixnum(to_fixnum(dpeek())));
}

CELL number_eq_fixnum(CELL x, CELL y)
{
	return tag_boolean(x == y);
}

CELL add_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) + untag_fixnum_fast(y));
}

CELL subtract_fixnum(CELL x, CELL y)
{
	CELL_TO_INTEGER(untag_fixnum_fast(x) - untag_fixnum_fast(y));
}

CELL multiply_fixnum(CELL _x, CELL _y)
{
	FIXNUM x = untag_fixnum_fast(_x);
	FIXNUM y = untag_fixnum_fast(_y);
	long long result = (long long)x * (long long)y;
	if(result < FIXNUM_MIN || result > FIXNUM_MAX)
	{
		return tag_object(s48_bignum_multiply(
			s48_long_to_bignum(x),
			s48_long_to_bignum(y)));
	}
	else
		return tag_fixnum(result);
}

CELL divint_fixnum(CELL x, CELL y)
{
	/* division takes common factor of 8 out. */
	/* we have to do SIGNED division here */
	return tag_fixnum((FIXNUM)x / (FIXNUM)y);
}

CELL divfloat_fixnum(CELL x, CELL y)
{
	/* division takes common factor of 8 out. */
	/* we have to do SIGNED division here */
	FIXNUM _x = (FIXNUM)x;
	FIXNUM _y = (FIXNUM)y;
	return tag_object(make_float((double)_x / (double)_y));
}

CELL divmod_fixnum(CELL x, CELL y)
{
	ldiv_t q = ldiv(x,y);
	/* division takes common factor of 8 out. */
	dpush(tag_fixnum(q.quot));
	return q.rem;
}

CELL mod_fixnum(CELL x, CELL y)
{
	return x % y;
}

FIXNUM gcd_fixnum(FIXNUM x, FIXNUM y)
{
	FIXNUM t;

	if(x < 0)
		x = -x;
	if(y < 0)
		y = -y;

	if(x > y)
	{
		t = x;
		x = y;
		y = t;
	}

	for(;;)
	{
		if(x == 0)
			return y;

		t = y % x;
		y = x;
		x = t;
	}
}

CELL divide_fixnum(CELL x, CELL y)
{
	FIXNUM _x = untag_fixnum_fast(x);
	FIXNUM _y = untag_fixnum_fast(y);
	FIXNUM gcd;

	if(_y == 0)
		raise(SIGFPE);
	else if(_y < 0)
	{
		_x = -_x;
		_y = -_y;
	}

	gcd = gcd_fixnum(_x,_y);
	if(gcd != 1)
	{
		_x /= gcd;
		_y /= gcd;
	}

	if(_y == 1)
		return tag_fixnum(_x);
	else
		return tag_ratio(ratio(tag_fixnum(_x),tag_fixnum(_y)));
}

CELL and_fixnum(CELL x, CELL y)
{
	return x & y;
}

CELL or_fixnum(CELL x, CELL y)
{
	return x | y;
}

CELL xor_fixnum(CELL x, CELL y)
{
	return x ^ y;
}

CELL shift_fixnum(CELL _x, FIXNUM y)
{
	FIXNUM x = untag_fixnum_fast(_x);
	if(y > CELLS * -8 && y < CELLS * 8)
	{
		long long result = (y < 0
			? (long long)x >> -y
			: (long long)x << y);

		if(result >= FIXNUM_MIN && result <= FIXNUM_MAX)
			return tag_fixnum(result);
	}

	return tag_object(s48_bignum_arithmetic_shift(
		s48_long_to_bignum(x),y));
}

CELL less_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x < (FIXNUM)y);
}

CELL lesseq_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x <= (FIXNUM)y);
}

CELL greater_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x > (FIXNUM)y);
}

CELL greatereq_fixnum(CELL x, CELL y)
{
	return tag_boolean((FIXNUM)x >= (FIXNUM)y);
}

CELL not_fixnum(CELL n)
{
	return RETAG(UNTAG(~n),FIXNUM_TYPE);
}
