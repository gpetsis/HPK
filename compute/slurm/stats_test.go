package slurm_test

import (
	"context"
	"runtime"
	"testing"

	"github.com/carv-ics-forth/hpk/compute"
	"github.com/carv-ics-forth/hpk/compute/slurm"
	corev1 "k8s.io/api/core/v1"
)

func TestTotalResources(t *testing.T) {
	tests := []struct {
		name     string
		runSlurm bool
	}{
		{
			name:     "non-slurm",
			runSlurm: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			originalRunSlurm := compute.Environment.RunSlurm
			compute.Environment.RunSlurm = tt.runSlurm
			defer func() {
				compute.Environment.RunSlurm = originalRunSlurm
			}()

			resources := slurm.TotalResources()

			cpu := resources[corev1.ResourceCPU]
			expectedCPU := int64(runtime.NumCPU())
			if cpu.Value() != expectedCPU {
				t.Errorf("TotalResources() CPU = %d, want %d", cpu.Value(), expectedCPU)
			}

			mem := resources[corev1.ResourceMemory]
			if mem.IsZero() {
				t.Error("TotalResources() Memory should not be zero")
			}

			storage := resources[corev1.ResourceStorage]
			if storage.IsZero() {
				t.Error("TotalResources() Storage should not be zero")
			}

			ephemeral := resources[corev1.ResourceEphemeralStorage]
			if ephemeral.IsZero() {
				t.Error("TotalResources() Ephemeral storage should not be zero")
			}

			pods := resources[corev1.ResourcePods]
			if pods.Value() != 110 {
				t.Errorf("TotalResources() Pods = %d, want 110", pods.Value())
			}

			expectedResources := []corev1.ResourceName{
				corev1.ResourceCPU,
				corev1.ResourceMemory,
				corev1.ResourceStorage,
				corev1.ResourceEphemeralStorage,
				corev1.ResourcePods,
			}

			for _, resName := range expectedResources {
				if _, exists := resources[resName]; !exists {
					t.Errorf("TotalResources() missing resource %s", resName)
				}
			}
		})
	}
}

func TestAllocatableResources(t *testing.T) {
	originalRunSlurm := compute.Environment.RunSlurm
	compute.Environment.RunSlurm = false
	defer func() {
		compute.Environment.RunSlurm = originalRunSlurm
	}()

	ctx := context.Background()
	allocatable := slurm.AllocatableResources(ctx)
	total := slurm.TotalResources()

	allocCPU := allocatable[corev1.ResourceCPU]
	totalCPU := total[corev1.ResourceCPU]
	if allocCPU.Value() != totalCPU.Value() {
		t.Errorf("AllocatableResources() CPU = %d, want %d", allocCPU.Value(), totalCPU.Value())
	}

	allocMem := allocatable[corev1.ResourceMemory]
	totalMem := total[corev1.ResourceMemory]
	if allocMem.Value() != totalMem.Value() {
		t.Errorf("AllocatableResources() Memory = %d, want %d", allocMem.Value(), totalMem.Value())
	}
}
