#include "arith.h"
#include "csidh_api.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#define BENCH_COUNT 10
#define ARITH_BENCH 20000
#define TEST_COUNT 1


int64_t cpucycles(void)
{ // Access system counter for benchmarking
    struct timespec time;

    clock_gettime(CLOCK_REALTIME, &time);
    return (int64_t)(time.tv_sec * 1e9 + time.tv_nsec);
}

int csidh_test()
{
    int i;
    public_key_t alice_pub, bob_pub;
    private_key_t alice_priv, bob_priv;
    shared_secret_t alice_shared, bob_shared;

    fp_init_zero(alice_pub->A);
    fp_init_zero(bob_pub->A);
    fp_init_zero(bob_shared->A);
    fp_init_zero(alice_shared->A);

    

      bool passed = true;
      bool valid = true;
  #ifdef _CONSTANT_
      printf("\n\nTESTING CONSTANT-TIME CSIDH KEY-EXCHANGE CSIDH_P511\n");
      printf("---------------------------------------------------\n\n");
  #else
      printf("\n\nTESTING NON-CONSTANT TIME CSIDH KEY-EXCHANGE CSIDH_P511\n");
      printf("-------------------------------------------------------\n\n");
  #endif
      for(i = 0; i < TEST_COUNT; i++)
      {
          csidh_keypair(alice_priv, alice_pub);
          csidh_keypair(bob_priv, bob_pub);

          valid = csidh_validate(bob_pub);
          valid = csidh_validate(alice_pub);
          csidh_sharedsecret(bob_pub, alice_priv, alice_shared);
          csidh_sharedsecret(alice_pub, bob_priv, bob_shared);

          if(memcmp(alice_shared, bob_shared, NWORDS_64 * 8) != 0)
          {
              passed = false;
              fp_print(alice_shared->A);fp_print(bob_shared->A);
              break;
          }
      }

      if (passed == true)
      {
          printf("   CSIDH tests..........................................PASSED\n\n");
          if(!valid)
          {
              printf("\n   Public-key Validation................................FAILED\n\n");
          }else
          {
              printf("\n   Public-key Validation................................PASSED\n\n");
          }
      }
      else
      {
          printf("   CSIDH tests..........................................FAILED\n\n");
          if(!valid)
          {
              printf("\n   Public-key Validation................................FAILED\n\n");
          }else
          {
              printf("\n   Public-key Validation................................PASSED\n\n");
          }

          return 0;   // FAILED
      }
      

    return 1; // PASSED
}

void csidh_bench()
{
    int i;
    public_key_t alice_pub, bob_pub;
    private_key_t alice_priv, bob_priv;
    shared_secret_t alice_shared, bob_shared;
    unsigned long long cycles, start, end, alice_total = 0, bob_total = 0;
    const int numbers_of_a = 5000, numbers_of_b = 5500, numbers_of_c = 6000;

    felm_t a[numbers_of_a] = {0}, b[numbers_of_b] = {0}, c[numbers_of_c] = {0};
    for (i = 0; i < numbers_of_c; i++)
    {
        fp_random_512(a[i % numbers_of_a]);
        fp_random_512(b[i % numbers_of_b]);
        fp_random_512(c[i % numbers_of_c]);
    }

        fp_init_zero(alice_pub->A);
        fp_init_zero(bob_pub->A);
        fp_init_zero(bob_shared->A);
        fp_init_zero(alice_shared->A);
        for(i = 0; i < NWORDS_64; i++)
        {
            alice_priv->exponents[i] = 0;
            bob_priv->exponents[i] = 0;
        }

    #ifdef _CONSTANT_
        printf("\n\nBENCHMARKING CONSTANT-TIME CSIDH KEY-EXCHANGE CSIDH_P511\n");
        printf("----------------------------------------------------------\n\n");
    #else
        printf("\n\nBENCHMARKING NON-CONSTANT TIME CSIDH KEY-EXCHANGE CSIDH_P511\n");
        printf("------------------------------------------------------------\n\n");
    #endif

        // Benchmarking key generation
        cycles = 0;
        for(i = 0; i < BENCH_COUNT; i++)
        {
            start = cpucycles();
            csidh_keypair(alice_priv, alice_pub);
            end = cpucycles();
            cycles = cycles + (end - start);
        }
        printf("Alice Key generation runs in..............................%10lld nsec\n", cycles/BENCH_COUNT);
        alice_total = cycles/BENCH_COUNT;

        cycles = 0;
        for(i = 0; i < BENCH_COUNT; i++)
        {
            start = cpucycles();
            csidh_keypair(bob_priv, bob_pub);
            end = cpucycles();
            cycles = cycles + (end - start);
        }
        printf("Bob Key generation runs in................................%10lld nsec\n", cycles/BENCH_COUNT);
        bob_total = cycles/BENCH_COUNT;

        // Benchmarking Public-key validation
        cycles = 0;
        for(i = 0; i < BENCH_COUNT; i++)
        {
            start = cpucycles();
            csidh_validate(bob_pub);
            end = cpucycles();
            cycles = cycles + (end - start);
        }
        printf("Alice validation of Bob's Public-Key runs in..............%10lld nsec\n", cycles/BENCH_COUNT);
        alice_total += cycles/BENCH_COUNT;

        cycles = 0;
        for(i = 0; i < BENCH_COUNT; i++)
        {
            start = cpucycles();
            csidh_validate(alice_pub);
            end = cpucycles();
            cycles = cycles + (end - start);
        }
        printf("Bob validation of Alice's Public-Key runs in..............%10lld nsec\n", cycles/BENCH_COUNT);
        bob_total += cycles/BENCH_COUNT;

        // Benchmarking shared-secret computations
        cycles = 0;
        for(i = 0; i < BENCH_COUNT; i++)
        {
            start = cpucycles();
            csidh_sharedsecret(bob_pub, alice_priv, alice_shared);
            end = cpucycles();
            cycles = cycles + (end - start);
        }
        printf("Alice Shared key generation runs in.......................%10lld nsec\n", cycles/BENCH_COUNT);
        alice_total += cycles/BENCH_COUNT;

        cycles = 0;
        for(i = 0; i < BENCH_COUNT; i++)
        {
            start = cpucycles();
            csidh_sharedsecret(alice_pub, bob_priv, bob_shared);
            end = cpucycles();
            cycles = cycles + (end - start);
        }
        printf("Bob Shared key generation runs in.........................%10lld nsec\n", cycles/BENCH_COUNT);
        bob_total += cycles/BENCH_COUNT;

        printf("\nAlice Total computations runs in.........................%10lld nsec\n", alice_total);
        printf("Bob Total computations runs in...........................%10lld nsec\n\n", bob_total);


    cycles = 0;
    start = cpucycles();
    for (i = 0; i < ARITH_BENCH; i++)
    {
        fp_mul_mont_512(a[i % numbers_of_a], b[i % numbers_of_b], c[i % numbers_of_c]);
    }
    end = cpucycles();
    cycles = cycles + (end - start);
    printf("\n..................BENCHMARKING MULTIPLICATION..................\n");
    printf("---------------------------------------------------------------\n\n");
    printf("fp_mul_mont_512 runs in ............................%6lld nsec\n\n", cycles / ARITH_BENCH);
    printf("...............................................................\n\n");

    return;
}

const int LIMBS = 8;
void printFelm(uint64_t *a) {
    for (int i = 0; i < 8; i++) {
        printf("0x%016llx\n", a[i]);
    }
    printf("\n");
}


void mul_test()
{

    //void fp_mul_mont_512(const uint64_t *a, const uint64_t *b, uint64_t *c);
    uint64_t r2_Mont[8] = { 0x36905b572ffc1724, 0x67086f4525f1f27d,
                        0x4faf3fbfd22370ca, 0x192ea214bcc584b1,
                        0x5dae03ee2f5de3d0, 0x1e9248731776b371,
                        0xad5f166e20e4f52d, 0x4ed759aea6f3917e };

    const uint64_t one[8] = {
        0x1,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
    };

    const uint64_t b[8] = {
        0x2,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
    };
    const uint64_t c[8] = {
        0x1b81b90533c6c87a,
        0xc2721bf457aca835,
        0x516730cc1f0b4f25,
        0xa7aac6c567f35507,
        0x5afbfcc69322c9cd,
        0xb42d083aedc88c42,
        0xfc8ab0d15e3e4c4a,
        0x65b48e8f740f89bf,
    };

    uint64_t mont_b[8], mont_c[8];

    uint64_t mont_result[8];
    uint64_t result[8];

    fp_mul_mont_512(r2_Mont, c, mont_b);
    fp_mul_mont_512(r2_Mont, c, mont_c);

    fp_mul_mont_512(mont_b, mont_c, mont_result);

    fp_mul_mont_512(one, mont_result, result);

    printFelm(result);

}


int main()
{
    csidh_bench();

    mul_test();

    int passed = 1;
    passed = csidh_test();

    if (!passed)
    {
        printf("\n\n Error: SHARED_KEY");
    }

    return passed;
}